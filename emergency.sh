#!/bin/bash
# emergency-maint.sh — usage: ./emergency-maint.sh <hostgroup> <minutes>
ZBX="https://zabbix.firma.pl/api_jsonrpc.php"
TOKEN="zbx_emergency_token"
GROUP_NAME="$1"   # np. "SAN/cluster-A"
DURATION_MIN="$2" # np. 30

NOW=$(date +%s)
END=$((NOW + DURATION_MIN*60))
GROUPID=$(curl -sk -H "Content-Type: application/json-rpc" -d "{
  \"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"id\":1,
  \"params\":{\"filter\":{\"name\":[\"$GROUP_NAME\"]},\"output\":[\"groupid\"]}
}" -H "Authorization: Bearer $TOKEN" $ZBX | jq -r '.result[0].groupid')

curl -sk -H "Content-Type: application/json-rpc" -d "{
  \"jsonrpc\":\"2.0\",\"method\":\"maintenance.create\",\"id\":1,
  \"params\":{
    \"name\":\"EMERGENCY $GROUP_NAME by $(whoami) at $(date -Is)\",
    \"active_since\":$NOW,
    \"active_till\":$END,
    \"groups\":[{\"groupid\":\"$GROUPID\"}],
    \"timeperiods\":[{\"timeperiod_type\":0,\"start_date\":$NOW,\"period\":$((DURATION_MIN*60))}],
    \"tags_evaltype\":0,
    \"maintenance_type\":0
  }
  }" -H "Authorization: Bearer $TOKEN" $ZBX | jq '.result, .error'

echo "Maintenance active for $DURATION_MIN min on group '$GROUP_NAME'"
