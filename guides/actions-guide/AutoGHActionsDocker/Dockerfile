# Get caddy image with builder tag as builder step
FROM caddy:builder AS builder

# Run xcaddy builder with plugins.
# Plugins can be found here: https://caddyserver.com/download
# Plugins in this template are:
# caddy-dns/cloudflare, caddyserver/ntlm-transport, sjtug/caddy2-filter, greenpau/caddy-auth-portal, caddyserver/transform-encoder
RUN xcaddy build --with github.com/caddy-dns/cloudflare --with github.com/caddyserver/ntlm-transport --with github.com/sjtug/caddy2-filter --with github.com/greenpau/caddy-auth-portal --with github.com/caddyserver/transform-encoder

# Get caddy alpine image to keep the container as small as possible
FROM caddy:alpine

# Copy caddy executable from builder step
COPY --from=builder /usr/bin/caddy /usr/bin/caddy