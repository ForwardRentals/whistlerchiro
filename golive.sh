#!/usr/bin/env bash
# Publishes whistlerchiro.com: GitHub repo + Pages + Cloudflare DNS.
# Run from Git Bash:  bash ~/whistlerchiro/golive.sh
set -e
cd "$(dirname "$0")"
REPO=ForwardRentals/whistlerchiro
ZONE=a30796cd28ae3d0b178584c620b22c76   # whistlerchiro.com on Cloudflare

gh repo create "$REPO" --public --source=. --push
gh api -X POST "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
gh api -X PUT "repos/$REPO/pages" -f cname=whistlerchiro.com >/dev/null

T=$(tr -d '\r\n ' < ~/cloudflare_token.txt)
add() { curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records" \
  -H "Authorization: Bearer $T" -H "Content-Type: application/json" \
  --data "{\"type\":\"$1\",\"name\":\"$2\",\"content\":\"$3\",\"proxied\":false,\"ttl\":1}" \
  | grep -o '"success":[a-z]*'; }
for ip in 185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153; do add A whistlerchiro.com $ip; done
add CNAME www forwardrentals.github.io

echo "Done. Preview now: https://forwardrentals.github.io/whistlerchiro/"
echo "whistlerchiro.com resolves in a few minutes. Once it does, run:"
echo "  gh api -X PUT repos/$REPO/pages -F https_enforced=true"
