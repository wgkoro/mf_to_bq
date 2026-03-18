# Makefile

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make validate  Validate MoneyForward CSV"
	@echo "  make create    Create Bq sql file"
	@echo "  make validate_sql Validate generated SQL by dry run"
	@echo "  make insert	Insert data to Bq"
	@echo "  make apply     Create sql file, and insert to Bq table"

.PHONY: validate
validate:
	@(ruby main.rb validate)

.PHONY: create
create:
	@(ruby main.rb)

.PHONY: validate_sql
validate_sql:
	@(echo "Start validating generated SQL by dry run")
	@(bq query --dry_run --use_legacy_sql=false < ./files/bq.sql)

.PHONY: insert
insert:
	@(echo "Start inserting data to Bq")
	@(bq query -use_legacy_sql=false < ./files/bq.sql)

.PHONY: apply
apply: validate create validate_sql insert
