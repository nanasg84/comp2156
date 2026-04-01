# Run Terraform
Write-Host "Running Terraform apply..."
# terraform init
terraform apply -auto-approve

# Get Public IP
$VM_IP = terraform output -raw public_ip
Write-Host "VM Public IP: $VM_IP"

# Wait for SSH (port 22)
Write-Host "Waiting for VM to be ready (SSH)..."
$maxAttempts = 20
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $result = Test-NetConnection -ComputerName $VM_IP -Port 22 -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded) {
        Write-Host "SSH is available!"
        break
    }

    Start-Sleep -Seconds 10
    $attempt++
}

if ($attempt -eq $maxAttempts) {
    Write-Host "VM not reachable via SSH. Exiting."
    exit 1
}

# Run Ansible
Write-Host "Running Ansible playbook..."

ansible-playbook ../ansible/site.yml `
  -i "$VM_IP," `
  -u azureuser `
  --private-key "$env:USERPROFILE\.ssh\id_rsa"

Write-Host "Deployment complete!"