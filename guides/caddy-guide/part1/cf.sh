#!/bin/bash
# This script queries cloudflare's website and pulls the list of IPv4 addresses. They are then loaded into a file to be used by Caddy.
# These IPs can be used for setting up trusted proxy configurations in web servers.
# Original file creator: https://caddy.community/t/trusted-proxies-with-cloudflare-my-solution/16124

CLOUDFLARE_IPSV4="https://www.cloudflare.com/ips-v4"
FILE_IPV4="./configs/cloudflare-proxies"

if [ -f "$FILE_IPV4" ] ; then
  rm "$FILE_IPV4"
fi

if [ -f /usr/bin/curl ]; then
  HTTP_STATUS=$(curl -sw '%{http_code}' -o $FILE_IPV4 $CLOUDFLARE_IPSV4)
  if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "FAILED. Reason: unable to download IPv4 list [Status code: $HTTP_STATUS]"
    exit 1
  fi
else
  echo "FAILED. Reason: curl wasn't found on this system."
  exit 1
fi

sed -i ':a;N;$!ba;s/\n/ /g' $FILE_IPV4
sed -i '1s/^/trusted_proxies /' $FILE_IPV4
exit 0