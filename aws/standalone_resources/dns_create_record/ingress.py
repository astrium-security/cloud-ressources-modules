import requests
import sys
import json
import os

url = "https://api.cloudflare.com/client/v4/accounts/"+sys.argv[1]+"/cfd_tunnel/"+sys.argv[2]+"/configurations"

headers = {
  'Authorization': 'Bearer ' + os.getenv('CLOUDFLARE_API_TOKEN'),
  'Content-Type': 'application/json'
}

response = requests.request("GET", url, headers=headers)
response = json.loads(response.text)

array = response["result"]["config"]["ingress"]

# Check if service exists already
service_exists = False
for item in array:
    if 'hostname' in item and item['hostname'] == sys.argv[3]:
        item['service'] = sys.argv[4]
        service_exists = True
        break

# If service does not exist, append new configuration
if not service_exists:
    array.insert(0, {'service': sys.argv[4], 'hostname': sys.argv[3]})

payload = json.dumps({
  "config": {
    "originRequest": {
      "connectTimeout": 10
    },
    "ingress": array
  }
})

response = requests.request("PUT", url, headers=headers, data=payload)

print (response.text)
