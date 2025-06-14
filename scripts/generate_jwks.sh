#!/bin/bash
# Generate N RSA key pairs for JWKS, with configurable algorithm and key size

# Defaults
NUM_KEYS=${1:-2}
ALG=${2:-RS256}
KEY_SIZE=${3:-2048}

TMPDIR="$(dirname "$0")/tmp"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/rsa*.json "$TMPDIR"/rsa*_pub.json

for i in $(seq 1 $NUM_KEYS); do
  KID=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  jose jwk gen -i "{\"alg\":\"$ALG\",\"use\":\"sig\",\"kid\":\"$KID\"}" -s $KEY_SIZE | jq '.keys[0]' > "$TMPDIR/rsa${i}.json"
  jose jwk pub -i "$TMPDIR/rsa${i}.json" > "$TMPDIR/rsa${i}_pub.json"
  echo "Generated rsa${i}.json and rsa${i}_pub.json with kid: $KID in $TMPDIR"
done

# Combine private keys into a JWKS at repo root
cat "$TMPDIR"/rsa*.json | jq -s '{"keys": .}' > "$(dirname "$0")/../jwks_private.json"

# Combine public keys into a JWKS at repo root
cat "$TMPDIR"/rsa*_pub.json | jq -s '{"keys": .}' > "$(dirname "$0")/../jwks_public.json"

echo "JWKS files created: jwks_private.json (private), jwks_public.json (public)"
