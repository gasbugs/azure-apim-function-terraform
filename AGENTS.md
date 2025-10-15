# Repository Guidelines

## Project Structure & Module Organization
Terraform configuration lives at the repo root: `main.tf` defines Azure resources, `provider.tf` pins provider versions, `variables.tf` supplies defaults, and `outputs.tf` exposes deployment URLs. The Function app sits in `function_app/` with a root `host.json` and a `hello_world/` folder containing `__init__.py` and `function.json`. Avoid editing `function_app.zip`; it regenerates automatically via the `archive_file` data source during `terraform apply`.

## Build, Test, and Development Commands
Run `terraform fmt -recursive` before committing to normalize formatting. `terraform init` bootstraps providers for a fresh checkout. `terraform validate` catches syntax and provider issues early. `terraform plan -out plan.tfplan` previews changes and produces an artifact you can share in reviews. `terraform apply plan.tfplan` deploys the plan once approved, and `terraform destroy` tears everything down. For quick function smoke tests without deploying, install Azure Functions Core Tools and run `func start --script-root function_app`.

## Coding Style & Naming Conventions
Use two-space indentation in Terraform files and group related blocks logically (providers, data sources, resources). Resource names should remain lower-kebab-case and reuse the `var.prefix` pattern plus the random suffix to avoid clashes. In Python, follow PEP 8: four-space indentation, descriptive variable names, and f-strings for responses. Keep the entry point signature `main(req: func.HttpRequest) -> func.HttpResponse` unchanged so Azure Functions can bind it.

## Testing Guidelines
Formats and validations are the minimum gate: `terraform fmt -check -recursive` and `terraform validate` must pass. Capture a `terraform plan` diff for every change and sanity-check expected resource mutations. When the function logic changes, exercise it locally via `func start` or against a deployed endpoint with `curl "$(terraform output -raw function_endpoint)"` (the output stays sensitive—handle with care).

## Commit & Pull Request Guidelines
Existing history uses short, imperative subjects (e.g., "init"); continue that style and keep subject lines under ~72 characters. Include a body when context or rollout steps are non-obvious. For pull requests, add a summary of changes, paste the latest `terraform plan` output (trim secrets), link related issues, and mention any manual follow-up such as state moves or credential rotations. Flag breaking or destructive operations directly in the PR description.

## Deployment & Configuration Tips
Authenticate with Azure via `az login` and select the target subscription before running Terraform. Prefer remote state for team work; if you must work locally, never commit updated `terraform.tfstate*` files. Rotate the `var.prefix` for parallel environments, and treat outputs containing keys as secrets—store them in your password manager, not the repo.
