install:
	poetry install

all:
	poetry run mkdocs build

dev:
	poetry run mkdocs serve
