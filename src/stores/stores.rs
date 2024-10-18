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

use thiserror::Error;

#[async_trait::async_trait]
pub trait ImporterStore {
    async fn insert_source(&self, url: &str) -> Result<(), ImporterStoreError>;
    async fn insert_content(
        &self,
        source_id: i32,
        status_code: u32,
        headers: &serde_json::Value,
        body: &str,
    ) -> Result<(), ImporterStoreError>;
    async fn fetch_and_process_post(
        &self,
        base_url: i32,
        post_id: i32,
    ) -> Result<(), ImporterStoreError>;

    async fn get_post_ids_and_process(&self, full_url: &str) -> Result<(), ImporterStoreError>;
}

#[derive(Debug, Error)]
pub enum ImporterStoreError {
    #[error("already exists")]
    AlreadyExists,
    #[error("not found")]
    NotFound,
}
