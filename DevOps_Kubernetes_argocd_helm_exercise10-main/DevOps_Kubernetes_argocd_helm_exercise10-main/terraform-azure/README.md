# Intall terraform
https://developer.hashicorp.com/terraform/install

# Run following command for terraform
```bash
terraform init
terraform validate
terraform plan

ssh-keygen -t rsa -b 4096 -C "azure-vm-key"
type $env:USERPROFILE\.ssh\id_rsa.pub
terraform plan
terraform apply

ssh azureuser@20.151.16.149
terraform destroY
```

# Run to execute shell or Powershell script
``` bash
chmod +x deploy.sh
.\deploy.ps1
terraform destroy
```






# Run Scripot

```
chmod +x deploy.sh
./deploy.sh
```