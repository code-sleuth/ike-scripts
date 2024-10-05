-- Copyright 2024 Ibrahim Mbaziira
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- migrate:up

--- create the enum types
-- doc_format type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'doc_format') THEN
        CREATE TYPE doc_format AS ENUM ('json', 'yml', 'yaml');
    END IF;
END $$;

-- natural_languages type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'natural_languages') THEN
        CREATE TYPE natural_languages AS ENUM ('en', 'fr');
    END IF;
END $$;

-- code_languages type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'code_languages') THEN
        CREATE TYPE code_languages AS ENUM ('python', 'sql', 'javascript');
    END IF;
END $$;

---vector extension
CREATE EXTENSION IF NOT EXISTS VECTOR;

-- sources table
CREATE TABLE IF NOT EXISTS sources (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    author_email VARCHAR(255),
    raw_url TEXT,
    scheme VARCHAR(10),
    host VARCHAR(255),
    path TEXT,
    query TEXT,
    active_domain BOOLEAN NOT NULL,
    format doc_format,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- downloads table
CREATE TABLE IF NOT EXISTS downloads (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id),
    attempted_at TIMESTAMPTZ,
    downloaded_at TIMESTAMPTZ,
    status_code INTEGER,
    headers JSONB NOT NULL,
    body TEXT
);

-- documents table
CREATE TABLE IF NOT EXISTS documents (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id),
    download_id UUID REFERENCES downloads(id),
    format doc_format,
    indexed_at TIMESTAMPTZ,
    min_chunk_size INTEGER NOT NULL,
    max_chunk_size INTEGER NOT NULL,
    published_at TIMESTAMPTZ,
    modified_at TIMESTAMPTZ,
    wp_version VARCHAR(10)
);

-- chunks table
CREATE TABLE IF NOT EXISTS chunks (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    parent_chunk_id UUID REFERENCES chunks(id),
    left_chunk_id UUID REFERENCES chunks(id),
    right_chunk_id UUID REFERENCES chunks(id),
    body TEXT,
    byte_size INTEGER,
    tokenizer VARCHAR(255),
    token_count INTEGER,
    natural_lang natural_languages,
    code_lang code_languages
);

-- tags table
CREATE TABLE IF NOT EXISTS tags (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- document tags
CREATE TABLE IF NOT EXISTS document_tags (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    tag_id UUID REFERENCES tags(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (document_id, tag_id)
);

-- document_meta table
CREATE TABLE IF NOT EXISTS document_meta (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    "key" VARCHAR(255) NOT NULL,
    meta JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (document_id, key)
);

-- embeddings table
CREATE TABLE IF NOT EXISTS embeddings (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    embedding_1536 VECTOR(1536),
    embedding_3072 VECTOR(3072),
    embedding_768 VECTOR(768),
    model VARCHAR(255),
    embedded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    object_id UUID REFERENCES chunks(id),
    object_type VARCHAR(20) NOT NULL DEFAULT 'chunk'
);

-- requests table
CREATE TABLE IF NOT EXISTS requests (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    message TEXT NOT NULL,
    meta JSONB,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result_chunks UUID[]
);

-- schema_migrations
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255)
);

-- indexes for search
CREATE INDEX idx_documents_source_id ON documents(source_id);
CREATE INDEX idx_downloads_source_id ON downloads(source_id);
CREATE INDEX idx_chunks_document_id ON chunks(document_id);
CREATE INDEX idx_document_tags_document_id ON document_tags(document_id);
CREATE INDEX idx_document_tags_tag_id ON document_tags(tag_id);
CREATE INDEX idx_document_meta_document_id ON document_meta(document_id);
CREATE INDEX idx_embeddings_object_id ON embeddings(object_id);

-- trigger function to maintain last 3 downloads
CREATE OR REPLACE FUNCTION trg_maintain_last_3_downloads()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM downloads
    WHERE source_id = NEW.source_id
    AND id NOT IN (
        SELECT id
        FROM downloads
        WHERE source_id = NEW.source_id
        ORDER BY downloaded_at DESC NULLS LAST
        LIMIT 3
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- maintain_last_3_downloads trigger
CREATE TRIGGER maintain_last_3_downloads
AFTER INSERT ON downloads
FOR EACH ROW
EXECUTE FUNCTION trg_maintain_last_3_downloads();
