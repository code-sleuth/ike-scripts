#    Copyright 2024 Ibrahim Mbaziira
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
FROM rust:1.81.0-alpine AS chef
USER root
# add cargo-chef to build project dependencies for optimal Docker layer caching.
RUN apk add --no-cache musl-dev & cargo install cargo-chef --locked
WORKDIR /app

FROM chef AS planner
COPY . .
# Capture informatiion needed to build dependencies
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies on the caching Docker layer!
RUN cargo chef cook --release --bin ike-scripts --recipe-path recipe.json
# Build binary
COPY . .
ENV SQLX_OFFLINE=true
RUN cargo build --release --bin ike-scripts

# build minimal image to publish
FROM debian:buster-slim AS runtime
ARG BUILD_DATE
ARG BUILD_VERSION
WORKDIR /app
COPY --from=builder /app/target/release/ike-scripts /usr/local/bin
ENTRYPOINT ["/usr/local/bin/ike-scripts"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.title="ibrahimmbaziira/ike-scripts" \
    org.opencontainers.image.authors="Ibrahim Mbaziira <code.ibra@gmail.com>" \
    org.opencontainers.image.source="https://github.com/code-sleuth/ike-scripts/tree/main" \
    org.opencontainers.image.revision="${BUILD_VERSION}" \
    org.opencontainers.image.vendor="Ibrahim Mbaziira"
