# Makefile

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make validate  Validate MoneyForward CSV"
	@echo "  make create    Create Bq sql file"
	@echo "  make insert	Insert data to Bq"
	@echo "  make apply     Create sql file, and insert to Bq table"

.PHONY: validate
validate:
	@(ruby main.rb validate)

.PHONY: create
create:
	@(ruby main.rb)

.PHONY: insert
insert:
	@(echo "Start inserting data to Bq")
	@(bq query -use_legacy_sql=false < ./files/bq.sql)

.PHONY: apply
apply: validate create insert
