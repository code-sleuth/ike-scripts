/*
   Copyright 2024 Ibrahim Mbaziira

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Clone)]
pub struct Document {
    pub id: Uuid,
    pub source_id: Uuid,
    pub download_id: Uuid,
    pub format: Option<DocsFormat>,
    pub indexed_at: Option<DateTime<Utc>>,
    pub min_chunk_size: u32,
    pub max_chunk_size: u32,
    pub published_at: Option<DateTime<Utc>>,
    pub modified_at: Option<DateTime<Utc>>,
    pub wp_version: Option<String>,
}

#[derive(Debug, Clone)]
pub enum DocsFormat {
    Json,
    Yml,
    Yaml,
}
