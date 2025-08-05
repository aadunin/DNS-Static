#!/bin/bash
set -e

mkdir -p mikrotik
echo "/ip dns static remove [find address-list=\"autohost\"]" > mikrotik/dns-static.rsc

declare -A seen
cnt=0

while read -r ip rest; do
  for d in $rest; do
    [[ "$ip" == "127.0.0.1" && "$d" =~ ^(local|localhost|localhost.localdomain)$ ]] && continue
    [[ "$ip" == "255.255.255.255" && "$d" == "broadcasthost" ]] && continue
    ip_addr=${ip/0.0.0.0/192.0.2.1}
    key="$ip_addr|$d"
    [[ -n "${seen[$key]}" ]] && continue
    seen[$key]=1
    echo "/ip dns static add name=$d address=$ip_addr ttl=1d address-list=autohost" >> mikrotik/dns-static.rsc
    cnt=$((cnt+1))
  done
done < <(grep -Ev '^(#|$)' hosts)

echo "/log info \"[update-hosts] Added $cnt entries\"" >> mikrotik/dns-static.rsc
echo ":: Generated $cnt unique entries"
echo "cnt=$cnt" >> $GITHUB_ENV
