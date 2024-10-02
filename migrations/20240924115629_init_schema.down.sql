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

-- migrate:down

-- drop trigger
DROP TRIGGER IF EXISTS maintain_last_3_downloads ON downloads;

-- drop trigger function
DROP FUNCTION IF EXISTS trg_maintain_last_3_downloads();

-- drop idexes
DROP INDEX IF EXISTS idx_embeddings_object_id;
DROP INDEX IF EXISTS idx_document_meta_document_id;
DROP INDEX IF EXISTS idx_document_tags_tag_id;
DROP INDEX IF EXISTS idx_document_tags_document_id;
DROP INDEX IF EXISTS idx_chunks_document_id;
DROP INDEX IF EXISTS idx_downloads_source_id;
DROP INDEX IF EXISTS idx_documents_source_id;

-- drop schema_migrations table
DROP TABLE IF EXISTS schema_migrations;

-- drop requests table
DROP TABLE IF EXISTS requests;

-- drop embeddings table
DROP TABLE IF EXISTS embeddings;

-- drop document_meta table
DROP TABLE IF EXISTS document_meta;

-- drop document_tags table
DROP TABLE IF EXISTS document_tags;

-- drop tags table
DROP TABLE IF EXISTS tags;

-- drop chunks table
DROP TABLE IF EXISTS chunks;

-- drop documents table
DROP TABLE IF EXISTS documents;

-- drop downloads table
DROP TABLE IF EXISTS downloads;

-- drop sources table
DROP TABLE IF EXISTS sources;

-- drop vector extension
DROP EXTENSION IF EXISTS VECTOR;

-- drop code_languages enum
DROP TYPE IF EXISTS code_languages;

-- drop natural_languages enum
DROP TYPE IF EXISTS natural_languages;

-- drop doc_format enum
DROP TYPE IF EXISTS doc_format;
