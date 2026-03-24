output "function_endpoint" {
  value       = "${azurerm_api_management.apim.gateway_url}/hello?name=홍길동&subscription-key=${random_password.sub_key.result}"
  sensitive   = true
  description = "The function endpoint URL (sensitive)"
}

output "test_curl_command" {
  value       = "curl \"${azurerm_api_management.apim.gateway_url}/hello?name=홍길동&subscription-key=${nonsensitive(random_password.sub_key.result)}\""
  description = "Copy and paste this command to test the API"
}

output "api_management_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}
