# Repository Guidelines

## Project Structure & Module Organization
Terraform lives at the repo root. `main.tf` provisions Azure resources, `provider.tf` locks provider versions, `variables.tf` captures defaults, and `outputs.tf` publishes endpoints. Azure Function code resides under `function_app/` with `host.json` at the root and the `hello_world/` function (`__init__.py`, `function.json`). Leave `function_app.zip` untouched—the `archive_file` data source recreates it during `terraform apply`.

## Build, Test, and Development Commands
Run `terraform fmt -recursive` to normalize style. Use `terraform init` for fresh checkouts, then `terraform validate` to catch syntax or provider errors. Capture planned changes with `terraform plan -out plan.tfplan`, and apply them via `terraform apply plan.tfplan`. Destroy environments with `terraform destroy`. For local smoke tests of the Function app, install Azure Functions Core Tools and run `func start --script-root function_app`.

## Coding Style & Naming Conventions
Terraform files use two-space indentation; cluster providers, data sources, and resources logically. Resource names follow lower-kebab-case and combine `var.prefix` with the random suffix so Azure names stay unique. Python code follows PEP 8—four spaces, descriptive identifiers, and f-strings for responses. Keep the Azure Functions signature `main(req: func.HttpRequest) -> func.HttpResponse` intact.

## Testing Guidelines
Before committing, run `terraform fmt -check -recursive` and `terraform validate`. Always review the latest `terraform plan` output to confirm only intended resources change. When function logic shifts, exercise it locally with `func start` or hit the deployed endpoint using `curl "$(terraform output -raw function_endpoint)"`; treat that URL as sensitive.

## Commit & Pull Request Guidelines
Commits use short, imperative subjects (e.g., "init") under ~72 characters. Add bodies when context, rollbacks, or manual steps need explanation. PRs should summarize impacts, attach the current `terraform plan` (scrub secrets), link related issues, and flag destructive operations. Note any follow-up tasks such as state migrations or credential rotations.

## Deployment & Configuration Tips
Authenticate with `az login` and select the target subscription before Terraform actions. Prefer remote state backends for team workflows; never commit `terraform.tfstate*`. Rotate `var.prefix` when creating parallel environments. Store sensitive outputs in a password manager, not the repository.
