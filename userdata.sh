#!/bin/bash -e

export AWS_DEFAULT_REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region)
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

yum install -y jq

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

oauth_client_id=$(aws ssm get-parameter --name "${tailscale_oauth_client_id_ssm_param}" --with-decryption --query "Parameter.Value" --output text)
oauth_client_secret=$(aws ssm get-parameter --name "${tailscale_oauth_client_secret_ssm_param}" --with-decryption --query "Parameter.Value" --output text)

access_token=$(curl -s -d "client_id=$oauth_client_id" -d "client_secret=$oauth_client_secret" \
              "https://api.tailscale.com/api/v2/oauth/token" | jq -r .access_token)

result=$(curl -sX POST "https://api.tailscale.com/api/v2/tailnet/harrison.ai/keys" \
      -u "$access_token:" \
      -H "Content-Type: application/json" \
      --data-binary '{
        "capabilities": {
          "devices": {
            "create": {
              "reusable": false,
              "ephemeral": true,
              "preauthorized": true,
              "tags": ${tailscale_tags}
            }
          }
        },
        "expirySeconds": 300
      }')

auth_key="$(jq -r '.key' <<< $result)"

curl -fsSL https://tailscale.com/install.sh | sh

tailscale up \
  --authkey $auth_key \
  --advertise-routes=${advertised_routes} \
  --hostname ${tailscale_machine_name}-$instance_id
