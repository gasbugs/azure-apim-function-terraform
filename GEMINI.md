# Project Overview

This project uses Terraform to provision an Azure Function App and an Azure API Management (APIM) instance. The Function App hosts a simple "Hello World" HTTP trigger function written in Python. The APIM instance is configured to expose the function through a managed API.

## Technologies Used

*   **Terraform:** For infrastructure as code (IaC) to define and manage Azure resources.
*   **Azure:** The cloud platform where the resources are deployed.
    *   Azure Function App: For running the serverless Python code.
    *   Azure API Management: To act as a gateway and publish the function as an API.
    *   Azure Storage: Used by the Function App for its operations.
    *   Azure Resource Group: To group all the created resources.
*   **Python:** The language used for the Azure Function.

## Architecture

The Terraform configuration in `main.tf` defines the following resources:

1.  A resource group to contain all the resources.
2.  A storage account for the Function App.
3.  An App Service Plan for the Function App.
4.  A Python-based Function App.
5.  An API Management instance.
6.  An API in APIM that imports the Function App's definition.
7.  A product in APIM to bundle the API.
8.  A subscription to the product to allow access to the API.

The Python function code is located in the `hello_world` directory. It's a simple HTTP trigger that responds with a greeting.

# Building and Running

To deploy the resources defined in this project, you will need to have Terraform and the Azure CLI installed and configured.

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
    This command initializes the Terraform working directory, downloading the necessary providers.

2.  **Plan the deployment:**
    ```bash
    terraform plan
    ```
    This command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

3.  **Apply the changes:**
    ```bash
    terraform apply
    ```
    This command applies the changes required to reach the desired state of the configuration. You will be prompted to confirm the changes before they are applied.

4.  **Access the API:**
    After the deployment is complete, you can access the API endpoint. The endpoint URL and subscription key will be available as outputs from the `terraform apply` command. You can also get them by running:
    ```bash
    terraform output function_endpoint
    terraform output subscription_key
    ```

5.  **Destroy the infrastructure:**
    To tear down all the resources created by this project, run:
    ```bash
    terraform destroy
    ```
    You will be prompted to confirm the destruction of the resources.

# Development Conventions

*   **Terraform Code:** All Terraform configuration files are located in the root of the project.
    *   `main.tf`: Defines the core Azure resources.
    *   `variables.tf`: Defines the variables used in the Terraform configuration.
    *   `outputs.tf`: Defines the outputs of the Terraform configuration.
    *   `provider.tf`: Configures the Terraform providers.
*   **Python Function Code:** The Python function code is located in the `hello_world` directory.
    *   `__init__.py`: The main entry point for the Azure Function.
    *   `function.json`: The configuration file for the Azure Function.
