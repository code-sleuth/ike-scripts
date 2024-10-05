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
pub struct Embedding {
    pub id: Uuid,
    pub embedding_1536: Option<PgVector>,
    pub embedding_3072: Option<PgVector>,
    pub embedding_768: Option<PgVector>,
    pub model: Option<String>,
    pub embedded_at: DateTime<Utc>,
    pub object_id: Uuid,
    pub object_type: String,
}

#[derive(Debug, Clone)]
pub struct PgVector(Vec<f32>);

impl PgVector {
    pub fn new_1536(vec: Vec<f32>) -> Option<Self> {
        if vec.len() == 1536 {
            Some(PgVector(vec))
        } else {
            None
        }
    }

    pub fn new_3072(vec: Vec<f32>) -> Option<Self> {
        if vec.len() == 3072 {
            Some(PgVector(vec))
        } else {
            None
        }
    }

    pub fn new_768(vec: Vec<f32>) -> Option<Self> {
        if vec.len() == 768 {
            Some(PgVector(vec))
        } else {
            None
        }
    }
}
