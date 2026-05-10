#!/bin/bash
# bulk-deps.sh - zaleznosci ICMP na core-router dla calej grupy
ZBX="https://zabbix.firma.pl/api_jsonrpc.php"
TOKEN="zbx_token_xxx"
MASTER_TRIG=14523   # ICMP loss > 50% on core-router

# 1) pobierz triggery 'agent ping' w grupie Linux/Production
TRIGGERS=$(curl -sk -H "Content-Type: application/json-rpc" \
  -H "Authorization: Bearer $TOKEN" -d '{
    "jsonrpc":"2.0","method":"trigger.get","id":1,
    "params":{
      "output":["triggerid","description"],
      "groupids":["12"],
      "search":{"description":"Unavailable by ICMP ping"}
    }
  }' $ZBX | jq -r '.result[].triggerid')

# 2) dla kazdego dodaj dependency
for T in $TRIGGERS; do
  curl -sk -H "Content-Type: application/json-rpc" \
    -H "Authorization: Bearer $TOKEN" -d "{
      \"jsonrpc\":\"2.0\",\"method\":\"trigger.update\",\"id\":1,
      \"params\":{
        \"triggerid\":\"$T\",
        \"dependencies\":[{\"triggerid\":\"$MASTER_TRIG\"}]
      }
    }" $ZBX | jq '.result, .error'
done
