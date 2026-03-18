#!/bin/sh
set -e

RULE_FILE="/var/lib/suricata/rules/suricata.rules"


touch /suricata-logs/suricata.fast.log

if [ ! -f "$RULE_FILE" ]; then
  echo "[*] Rules not found, running suricata-update..."
  suricata-update
else
  echo "[*] Rules already exist, skip update"
fi

exec suricata -i enp2s0 -c /etc/suricata/suricata.yaml
