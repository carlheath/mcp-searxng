# MCP SearXNG Server with HTTP Transport
# Based on isokoliuk/mcp-searxng - adds Coolify-ready configuration
#
# Usage in Coolify: Deploy with HTTP transport enabled
# The upstream image already supports everything we need

FROM isokoliuk/mcp-searxng:latest

# Default to HTTP transport mode
ENV MCP_HTTP_PORT=3000
ENV NODE_ENV=production

# Health check for Coolify
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${MCP_HTTP_PORT}/health || exit 1

EXPOSE 3000

# The upstream image already has the correct entrypoint
