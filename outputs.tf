output "function_endpoint" {
  value = "${azurerm_api_management.apim.gateway_url}/hello?name=홍길동&subscription-key=${azurerm_api_management_subscription.sub.primary_key}"
  sensitive = true
}

output "subscription_key" {
  value = azurerm_api_management_subscription.sub.primary_key
  sensitive = true
}

output "api_management_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}
