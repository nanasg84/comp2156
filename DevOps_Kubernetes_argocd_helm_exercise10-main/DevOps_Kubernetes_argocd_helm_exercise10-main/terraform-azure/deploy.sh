#!/bin/bash

terraform apply -auto-approve

VM_IP=$(terraform output -raw public_ip)

echo "VM IP: $VM_IP"
echo "Waiting for SSH..."

while ! nc -z $VM_IP 22; do
  sleep 5
done

ansible-playbook ../ansible/site.yml \
  -i "$VM_IP," \
  -u azureuser \
  --private-key ~/.ssh/id_rsa