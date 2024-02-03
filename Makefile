# Makefile

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make create    Create Bq sql file"
	@echo "  make insert	Insert data to Bq"
	@echo "  make apply     Create sql file, and insert to Bq table"

.PHONY: create
create:
	@(ruby to_sql.rb)

.PHONY: insert
insert:
	@(echo "Start inserting data to Bq")
	@(bq query -use_legacy_sql=false < ./files/bq.sql)

.PHONY: apply
apply: create insert
