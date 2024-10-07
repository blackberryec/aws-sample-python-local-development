# Define variables
ENV_FILE := .env
BUILD_DIR := .aws-sam/build
LAMBDA_SRC_DIR := src
LAYER_DIR := layers
ARTIFACTS_DIR := build_artifacts
PACKAGED_TEMPLATE := packaged-template.yaml
S3_BUCKET := your-s3-bucket-name  # Replace with your actual S3 bucket name

# Get all Lambda directories dynamically
LAMBDA_DIRS := $(shell find $(LAMBDA_SRC_DIR) -mindepth 1 -maxdepth 1 -type d)
LAYER_DIRS := $(shell find $(LAYER_DIR) -mindepth 1 -maxdepth 1 -type d)

# Install project dependencies using Poetry
.PHONY: install
install:
	poetry install

# Export dependencies for each Lambda
.PHONY: deps-lambdas
deps-lambdas:
	@echo "Export dependencies for Lambdas..."
	@for dir in $(LAMBDA_DIRS); do \
		lambda_name=$$(basename $$dir); \
		echo "Processing $$lambda_name..."; \
		if poetry show --with $$lambda_name > /dev/null 2>&1; then \
        	poetry export -f requirements.txt --with $$lambda_name --output $$dir/requirements.txt --without-hashes; \
		else \
			poetry export -f requirements.txt --output $$dir/requirements.txt --without-hashes; \
		fi \
	done

# Export dependencies for each layer
.PHONY: deps-layers
deps-layers:
	@echo "Export dependencies for layers..."
	@for dir in $(LAYER_DIRS); do \
		layer_name=$$(basename $$dir); \
		echo "Processing $$layer_name..."; \
		if poetry show --with $$layer_name > /dev/null 2>&1; then \
        	poetry export -f requirements.txt --with $$layer_name --output $$dir/requirements.txt --without-hashes; \
		else \
			poetry export -f requirements.txt --output $$dir/requirements.txt --without-hashes; \
		fi \
	done

# Export dependencies
.PHONY: deps
deps: clean deps-lambdas deps-layers

# Build the SAM application
.PHONY: build
build: deps
	sam validate --lint
	sam build --parallel

# Package the application using SAM package
.PHONY: package
sam-package: build
	@echo "Packaging application using sam package..."
	sam package --s3-bucket $(S3_BUCKET) --output-template-file $(PACKAGED_TEMPLATE)

# Package build artifacts into ZIP files
.PHONY: package
package: build
	@echo "Packaging build artifacts..."
	mkdir -p $(ARTIFACTS_DIR)
	@for dir in $(BUILD_DIR)/*/; do \
		artifact_name=$$(basename $$dir); \
		echo "Zipping contents of $$artifact_name..."; \
		(cd $$dir && zip -r $(CURDIR)/$(ARTIFACTS_DIR)/$$artifact_name.zip .); \
	done

# Run tests using pytest
.PHONY: test
test:
	PYTHONPATH=layers:$(shell find layers -mindepth 1 -maxdepth 1 -type d | tr '\n' ':')$(PYTHONPATH) poetry run pytest tests/

# Run the application locally using the default environment
.PHONY: local
local:
	sam local start-api --env-vars $(ENV_FILE)

# Clean build artifacts
.PHONY: clean
clean:
ifeq ($(OS),Windows_NT)
	# Windows environment (using PowerShell syntax)
	@if exist .pytest_cache rmdir /s /q .pytest_cache
	@if exist __pycache__ rmdir /s /q __pycache__
	@if exist $(ARTIFACTS_DIR) rmdir /s /q $(ARTIFACTS_DIR)
	@del /s /q **\__pycache__ **\requirements.txt .mypy_cache .coverage
else
	# Unix/Linux environment
	rm -rf .pytest_cache __pycache__ **/__pycache__ **/**/__pycache__ **/**/requirements.txt .mypy_cache .coverage $(ARTIFACTS_DIR)
endif

# Show help information
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  install          - Install project dependencies using Poetry"
	@echo "  deps-lambdas     - Export dependencies for each Lambda function"
	@echo "  deps-layers      - Export dependencies for each Layer"
	@echo "  deps             - Export all dependencies (Lambdas and layers) after cleaning"
	@echo "  build            - Validate the SAM template and build the application"
	@echo "  sam-package      - Package the application using SAM package into an S3 bucket"
	@echo "  package          - Package build artifacts into ZIP files"
	@echo "  test             - Run unit tests using pytest"
	@echo "  local            - Run the application locally using SAM"
	@echo "  clean            - Clean up build artifacts and cached files"
	@echo "  help             - Show this help information"