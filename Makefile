.PHONY: help, build, re-build, bash, download-test-data, test-windows, pre-commit-windows, init-test, pytest, clean
-include ado.env # Kiro: pulls in enviornment variables from ado.env file if present but the leading "-" means "don't error if not found"

help: ## Display help
	@grep -E '^[a-zA-Z_-]+:.*?## .$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker-run: ## Build docker image used for deployment
	docker run --rm -it -v ${PWD}:/app -t python:3.10 bash

# Windows commands
pre-commit-formatting: 
	SKIP=unit-tests,coverage pre-commit run --all-files

# CLI commands
init-test:
	@ pip install -r tests/requirements.txt

# TODO: create and populate a test data s3 bucket
download-test-data: init-test
	@ mkdir -p tests/data
	@ aws s3 cp s3://your-s3-bucket/folder/ --recursive 

test: download-test-data
	python -m coverage run -m pytest

coverage: 
	python -m coverage report --fail-under=70

clean: 
	@ rm -rf tests/data
	@ rm -rf *.json *.pkl *.tar.gz tests/*.csv test-output.xml .coverage