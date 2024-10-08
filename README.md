# AWS Serverless Application

This project is an AWS Serverless application built using AWS SAM, Python, and Poetry for dependency management. It includes Lambda functions with shared layers and automated local packaging.

## Project Structure

```plaintext
aws-serverless-app/
│
├── layers/                      # Contains shared layers for Lambda functions, with dependencies installed directly in each layer directory.
│   ├── shared_layer_one/
│   │   ├── __init__.py
│   │   ├── utils_one.py
│   ├── shared_layer_two/
│   │   ├── __init__.py
│   │   ├── utils_two.py
│
├── src/                         # Contains Lambda function source code.
│   ├── my_lambda/
│   │   ├── __init__.py
│   │   ├── handler.py
│   ├── another_lambda/
│   │   ├── __init__.py
│   │   ├── handler.py
│
├── api/                         # OpenAPI specification (if using API Gateway).
│   └── openapi.yaml
├── build_artifacts/             # Directory for storing locally packaged Lambda ZIP files.
│
├── .env                         # Environment variables for local development.
│
├── .gitignore                   # Ignore files for Git
│
├── Makefile                     # Automates build, package, and test tasks.
│
├── template.yaml                # SAM template for defining the serverless application.
│
├── pyproject.toml               # Poetry configuration file for managing dependencies
│
├── README.md                    # Documentation for the project
│
└── tests/                       # Unit tests for Lambda functions and layers
    ├── layers/
    │   ├── test_shared_layer_one.py
    │   ├── test_shared_layer_two.py
    ├── test_my_lambda.py
    └── test_another_lambda.py
```

## Prerequisites

- Python 3.9
- Poetry
- AWS SAM CLI
- Make
- Docker

## Setup

1. Install dependencies:

    ```bash
    make install
    ```

2. Install Lambdas and Layers dependencies:

    ```bash
    make deps
    ```

3. Build the application:

    ```bash
    make build
    ```

4. Package the application using SAM package into an S3 bucket:

    ```bash
    make sam-package
    ```
    
5. Package build artifacts into ZIP files:

    ```bash
    make package
    ```

6. Run the application locally:

    ```bash
    make local
    ```

7. Run tests:

    ```bash
    make test
    ```

8. Clean up build artifacts:

    ```bash
    make clean
    ```

## Adding New Dependencies

### Adding Dependencies to a Specific Lambda Function

- Use the following command to add a new dependency to a specific Lambda function (e.g., `my_lambda`). This will automatically update the `pyproject.toml` file:

    ```bash
    poetry add --group my_lambda <dependency-name>
    ```

    For example, to add `requests` to `my_lambda`:

    ```bash
    poetry add --group my_lambda requests
    ```

### Adding Dependencies to a Specific Layer

- Use the following command to add a new dependency to a specific layer (e.g., `shared_layer_one`). This will automatically update the `pyproject.toml` file:

    ```bash
    poetry add --group shared_layer_one <dependency-name>
    ```

    For example, to add `boto3` to `shared_layer_one`:

    ```bash
    poetry add --group shared_layer_one boto3
    ```

## Notes

- Dependencies for both the application and layers are managed using Poetry.
- The `Makefile` dynamically handles the installation of dependencies for each Lambda and layer.
- Adding new Lambdas or layers requires minimal changes—just add the source files and dependencies to `pyproject.toml`.
