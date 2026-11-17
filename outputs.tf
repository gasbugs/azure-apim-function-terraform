output "function_endpoint" {
  value       = "${azurerm_api_management.apim.gateway_url}/hello?name=홍길동&subscription-key=${random_password.sub_key.result}"
  sensitive   = true
  description = "The function endpoint URL (sensitive)"
}

output "test_curl_command" {
  value       = "curl \"${azurerm_api_management.apim.gateway_url}/hello?name=홍길동&subscription-key=${random_password.sub_key.result}\""
  sensitive   = true
  description = "Copy and paste this command to test the API"
}

output "subscription_key" {
  value       = azurerm_api_management_subscription.sub.primary_key
  sensitive   = true
  description = "APIM subscription key; send as Ocp-Apim-Subscription-Key header"
}

output "api_endpoint" {
  value       = "${azurerm_api_management.apim.gateway_url}/hello/"
  description = "APIM endpoint without credentials"
}

output "api_management_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}
