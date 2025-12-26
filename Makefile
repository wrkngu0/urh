# Makefile for developer convenience using uv
.PHONY: uv-sync test format build install-venv

uv-sync:
	uv sync

format:
	uv format .

test:
	# Run tests via uv-managed environment
	uv run pytest -q tests

build:
	uv build

install-venv:
	uv venv -p python3 -n .venv
