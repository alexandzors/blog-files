#!/usr/bin/env sh
# This script queries cloudflare's website and pulls the list of IPv4 addresses. They are then loaded into a file to be used by Caddy.
# These IPs can be used for setting up trusted proxy configurations in web servers.
# Original file creator: https://caddy.community/t/trusted-proxies-with-cloudflare-my-solution/16124
# Updated by https://github.com/calvinhenderson to be more "succinct" as he put it. :)

FILE_IPV4="./configs/cloudflare-proxies"
tmp_file="/var/tmp/cloudflare-ips-v4-$(date +%Y%m%d_%H%M%S)"

# Make sure curl exists
command -v curl >/dev/null || { echo "Command 'curl' was not found. Is it in the PATH?"; exit 1; }

# Fetch the IP list from Cloudflare
curl -fso "$tmp_file" "https://www.cloudflare.com/ips-v4"
[ $? -eq 0 ] || { echo "Failed to fetch IPv4 list."; exit 1; }

# Transform the downloaded list into a format Caddy can understand
awk -v d=" " '{s=(NR==1?s:s d)$0}END{print "trusted_proxies "s}' "$tmp_file" > "$FILE_IPV4"

# Clean up
rm -f "$tmp_file"
