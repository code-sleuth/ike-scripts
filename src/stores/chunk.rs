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
use uuid::Uuid;

#[derive(Debug, Clone)]
pub struct Chunk {
    pub id: Uuid,
    pub document_id: Uuid,
    pub parent_chunk_id: Uuid,
    pub left_chunk_id: Uuid,
    pub right_chunk_id: Uuid,
    pub body: Option<String>,
    pub byte_size: Option<i32>,
    pub tokenizer: Option<String>,
    pub token_count: Option<i32>,
    pub natural_lang: Option<NaturalLanguages>,
    pub code_lang: Option<CodeLanguages>,
}

#[derive(Debug, Clone)]
pub enum NaturalLanguages {
    En,
    Fr,
}

#[derive(Debug, Clone)]
pub enum CodeLanguages {
    Python,
    Sql,
    Javascript,
}
