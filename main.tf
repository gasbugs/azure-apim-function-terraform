resource "random_string" "unique" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function_app"
  output_path = "${path.module}/function_app.zip"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg-${random_string.unique.result}"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}sa${random_string.unique.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-plan-${random_string.unique.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "func" {
  name                       = "${var.prefix}-func-${random_string.unique.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  service_plan_id             = azurerm_service_plan.plan.id
  storage_account_name        = azurerm_storage_account.sa.name
  storage_account_access_key  = azurerm_storage_account.sa.primary_access_key
  zip_deploy_file             = data.archive_file.function_zip.output_path

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}

resource "azurerm_api_management" "apim" {
  name                = "${var.prefix}-apim-${random_string.unique.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Developer_1"
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_function_app_host_keys" "example" {
  name                = azurerm_linux_function_app.func.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_api_management_named_value" "function_key" {
  name                = "function-key"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Function-Key"
  value               = data.azurerm_function_app_host_keys.example.default_function_key
  secret              = true
}

resource "azurerm_api_management_api" "api" {
  name                = "${var.prefix}-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Hello Python API"
  path                = "hello"
  protocols           = ["https"]

}

resource "azurerm_api_management_api_operation" "get" {
  operation_id        = "get-hello"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get Hello"
  method              = "GET"
  url_template        = "/"
  
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_policy" "api_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service base-url="https://${azurerm_linux_function_app.func.default_hostname}" />
    <rewrite-uri template="/api/hello_world" />
    <set-query-parameter name="code" exists-action="override">
      <value>{{function-key}}</value>
    </set-query-parameter>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}

resource "azurerm_api_management_product" "product" {
  product_id            = "starter"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
  display_name          = "Starter"
  approval_required     = false
  published             = true
  subscription_required = true
}

resource "azurerm_api_management_product_api" "product_api" {
  product_id            = azurerm_api_management_product.product.product_id
  api_name              = azurerm_api_management_api.api.name
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_api_management_subscription" "sub" {
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
  product_id            = azurerm_api_management_product.product.id
  display_name          = "test-sub"
  primary_key           = null
}
