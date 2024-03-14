# lanchonete-lambda-infra

Para configurar as credencias IAM localmente e  autenticar o Terraform na AWS, configure o arquivo ~/.aws/credentials com as credencias da conta AWS.

```
[default]
aws_access_key_id=XXXXXX
aws_secret_access_key=YYYYYY
aws_session_token=ZZZZZZ
```

## Como criar infra Cognito e o primeiro usuário

1. Criar infra com o terraform
```
terraform init

terraform plan

terraform apply cognito.tf -auto-approve
```

2. Criar usuario adm - necessário aws cli e jq instalados
```
aws cognito-idp sign-up --client-id (aws cognito-idp list-user-pool-clients --user-pool-id (aws cognito-idp list-user-pools --max-results 1 | jq -r .UserPools[].Id) | jq -r .UserPoolClients[].ClientId) --username adm@lanchoneteg11.com --password adm12345 --user-attributes Name=name,Value=adm Name=email,Value=adm@lanchoneteg11.com
```

3. Confirmar usuário adm
```
aws cognito-idp admin-confirm-sign-up --user-pool-id (aws cognito-idp list-user-pools --max-results 1 | jq -r .UserPools[].Id) --username adm@lanchoneteg11.com
```

4. Obter token
```
aws cognito-idp initiate-auth --client-id (aws cognito-idp list-user-pool-clients --user-pool-id (aws cognito-idp list-user-pools --max-results 1 | jq -r .UserPools[].Id) | jq -r .UserPoolClients[].ClientId) --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=adm@lanchoneteg11.com,PASSWORD=adm12345 --query 'AuthenticationResult.IdToken' --output text
```