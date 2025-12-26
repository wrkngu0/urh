# Makefile for developer convenience using uv
.PHONY: uv-sync test format build install-venv

uv-sync:
	uv sync

format:
	uv format .

format-check:
	uv format --check .

format-fix:
	uv format . --

lint:
	# Run ruff checks on source and tests
	uv run ruff check src tests

test:
	# Run tests via uv-managed environment
	uv run pytest -q tests

build:
	uv build

install-venv:
	uv venv -p python3 -n .venv

pre-commit-install:
	# Install pre-commit hooks using uv-managed pre-commit
	uv run pre-commit install
