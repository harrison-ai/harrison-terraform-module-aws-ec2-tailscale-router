.PHONY: .tf_version

DATESTRING := $(shell date +%FT%H-%M-%S)
TF_VERSION := $(shell cat .tf_version)
.DEFAULT_GOAL := help

TF_DIR = examples/tailscale-router

.EXPORT_ALL_VARIABLES:
	export TF_VERSION=${TF_VERSION}

## init:			terraform init
init:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform init

## init-upgrade:		terraform init -upgrade
init-upgrade:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform init -upgrade

## fmt: 			terraform fmt -recursive
fmt:
	docker compose run --rm --workdir /app terraform fmt -recursive

## ci-fmt:			terraform fmt -recursive -check -diff -write=false
ci-fmt:
	docker compose run --rm --workdir /app terraform fmt -recursive -check -diff -write=false

## plan:			terraform plan
plan:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform plan

## plan-print:		terraform plan -no-color | tee plan-<date>.out
plan-print:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform plan -no-color | tee plan-${DATESTRING}.out

## apply:			terraform apply
apply:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform apply

## validate: 		terraform validate across all environments
validate:
	docker compose run --rm --workdir /app terraform init -backend=false
	docker compose run --rm --workdir /app terraform validate -json

## destroy:		terraform destroy
destroy:
	docker compose run --rm --workdir /app/$(TF_DIR) terraform destroy

## tf-shell:		opens a shell inside the terraform container
tf-shell:
	docker compose run --rm --entrypoint='' terraform /bin/ash

## pull:			docker compose pull
pull:
	docker compose pull

## help:			show this help
help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)
