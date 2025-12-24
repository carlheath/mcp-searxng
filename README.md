# MCP SearXNG

A Docker-ready [Model Context Protocol](https://modelcontextprotocol.io/) server for [SearXNG](https://docs.searxng.org/) search. Designed for deployment on Coolify with Bearer token authentication via Traefik.

Based on [ihor-sokoliuk/mcp-searxng](https://github.com/ihor-sokoliuk/mcp-searxng).

## Features

- **Web Search**: Query SearXNG with pagination, language, time filters, and safe search
- **URL Content Reading**: Fetch and convert web pages to markdown with section extraction
- **HTTP Transport**: Native HTTP/REST API (no stdio wrapper needed)
- **Coolify Ready**: Health checks, Traefik labels for auth, environment-based config

## Quick Start

### Local Development

```bash
# Clone and configure
git clone https://github.com/carlheath/mcp-searxng.git
cd mcp-searxng
cp .env.example .env
# Edit .env with your SEARXNG_URL and MCP_AUTH_TOKEN

# Run without auth (development)
docker-compose up -d

# Test
curl http://localhost:3000/health
```

### Local with Auth (Testing)

```bash
# Generate a token
export MCP_AUTH_TOKEN=$(openssl rand -hex 32)
echo "MCP_AUTH_TOKEN=$MCP_AUTH_TOKEN" >> .env

# Run with Caddy proxy
docker-compose --profile with-auth up -d

# Test (port 3001 requires auth)
curl http://localhost:3001/health  # Works without auth
curl -H "Authorization: Bearer $MCP_AUTH_TOKEN" http://localhost:3001/mcp  # Requires auth
```

## Coolify Deployment

### Step 1: Create New Service

1. In Coolify, create a new **Docker Compose** service
2. Point to this GitHub repo
3. Set environment variables:
   - `SEARXNG_URL=https://searxng.ogmios.se`
   - `MCP_AUTH_TOKEN=<generate with openssl rand -hex 32>`

### Step 2: Configure Domain

Set your domain (e.g., `mcp-searxng.ogmios.se`) in Coolify's domain settings.

### Step 3: Add Traefik Auth Labels

In Coolify, add these labels to enable Bearer token authentication:

```yaml
traefik.http.middlewares.mcp-auth.headers.customrequestheaders.authorization: "Bearer ${MCP_AUTH_TOKEN}"
```

Or use Coolify's built-in basic auth if preferred.

## Claude Code Integration

Once deployed, add to Claude Code:

```bash
claude mcp add --transport http searxng https://mcp-searxng.ogmios.se/mcp \
  --header "Authorization: Bearer YOUR_TOKEN"
```

Or in `.claude/settings.json`:

```json
{
  "mcpServers": {
    "searxng": {
      "type": "http",
      "url": "https://mcp-searxng.ogmios.se/mcp",
      "headers": {
        "Authorization": "Bearer ${MCP_AUTH_TOKEN}"
      }
    }
  }
}
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check (no auth required) |
| `/mcp` | POST | MCP protocol endpoint |

## MCP Tools

### `searxng_web_search`

Search the web via SearXNG.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Search query |
| `pageno` | number | No | Page number (default: 1) |
| `time_range` | string | No | Filter: "day", "month", "year" |
| `language` | string | No | Language code (e.g., "sv", "en") |
| `safesearch` | number | No | 0: Off, 1: Moderate, 2: Strict |

### `web_url_read`

Fetch and convert URL content to markdown.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | URL to fetch |
| `startChar` | number | No | Start position |
| `maxLength` | number | No | Max characters |
| `section` | string | No | Extract specific heading |
| `readHeadings` | boolean | No | Return only headings |

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SEARXNG_URL` | Yes | - | Your SearXNG instance URL |
| `MCP_AUTH_TOKEN` | Yes | - | Bearer token for authentication |
| `MCP_HTTP_PORT` | No | 3000 | HTTP port |
| `AUTH_USERNAME` | No | - | SearXNG basic auth username |
| `AUTH_PASSWORD` | No | - | SearXNG basic auth password |

## License

MIT
