output "api_gateway_url" {
  value = aws_api_gateway_rest_api.finance_app.execution_arn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.finance_app.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.finance_app.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.finance_app.name
}

output "ecs_service_name" {
  value = aws_ecs_service.finance_app.name
}