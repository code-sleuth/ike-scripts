#  Copyright 2024 Ibrahim Mbaziira
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

SERVICE=ike-scripts
COMMIT=$(shell sh -c 'git rev-parse --short HEAD')

#------------------------------------------------------------------------------
# Detect architecture
#------------------------------------------------------------------------------
ifeq "$(shell uname -p)" "arm"
	BUILD_ARCH=arm64
endif
ifeq "$(shell uname -p)" "x86_64"
	BUILD_ARCH=amd64
endif

#------------------------------------------------------------------------------
# Detect OS
#------------------------------------------------------------------------------
ifeq "$(shell uname -s)" "Darwin"
	BUILD_HOST=darwin
endif
ifeq "$(shell uname -s)" "Linux"
	BUILD_HOST=linux
endif

#------------------------------------------------------------------------------
# Set Rust target based on detected arch and OS
#------------------------------------------------------------------------------
ifeq ($(BUILD_HOST),darwin)
    ifeq ($(BUILD_ARCH),arm64)
        RUST_TARGET := aarch64-apple-darwin
    else ifeq ($(BUILD_ARCH),amd64)
        RUST_TARGET := x86_64-apple-darwin
    endif
else ifeq ($(BUILD_HOST),linux)
    ifeq ($(BUILD_ARCH),arm64)
        RUST_TARGET := aarch64-unknown-linux-gnu
    else ifeq ($(BUILD_ARCH),amd64)
        RUST_TARGET := x86_64-unknown-linux-gnu
    endif
endif

#------------------------------------------------------------------------------
# Docker platform based on architecture
#------------------------------------------------------------------------------
ifeq ($(BUILD_ARCH),arm64)
    DOCKER_PLATFORM := linux/arm64
else ifeq ($(BUILD_ARCH),amd64)
    DOCKER_PLATFORM := linux/amd64
endif

.PHONY: build

build:
	@echo "Building for target: $(RUST_TARGET)"
	cargo install cargo-watch
	cargo build --target $(RUST_TARGET)

run:
	cargo watch -x run

test:
	cargo test

compose-build:
	docker compose build

compose-run:
	docker compose up

docker-build-linux:
	@echo "Building image for platform: $(DOCKER_PLATFORM)"
	docker build . -t $(SERVICE) --platform $(DOCKER_PLATFORM)

docker-build:
	docker build . -t $(SERVICE)

verify-license-headers:
	./scripts/license.sh
