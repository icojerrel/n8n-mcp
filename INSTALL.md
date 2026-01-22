# n8n-mcp Installation Guide

Complete installation guide for setting up n8n-mcp on your system to start building workflows with Claude.

**Last Updated**: 2026-01-22
**Version**: 2.33.2

---

## Prerequisites

### Required Software

1. **Node.js** (v18 or higher)
   ```bash
   node --version  # Should be v18.0.0 or higher
   ```

2. **npm** (v9 or higher)
   ```bash
   npm --version  # Should be v9.0.0 or higher
   ```

3. **Git**
   ```bash
   git --version  # Any recent version
   ```

### Optional (Recommended)

4. **Claude Desktop** - For MCP integration
   - Download from: https://claude.ai/download

5. **n8n Instance** - For workflow deployment
   - Cloud: https://n8n.io
   - Self-hosted: https://docs.n8n.io/hosting/

---

## Installation Methods

### Method 1: Automated Installation (Recommended)

```bash
# Clone repository
git clone https://github.com/icojerrel/n8n-mcp.git
cd n8n-mcp

# Run installation script
chmod +x install.sh
./install.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Install npm dependencies
- ✅ Build TypeScript
- ✅ Initialize database
- ✅ Run validation tests
- ✅ Setup Claude Desktop config (optional)

### Method 2: Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/icojerrel/n8n-mcp.git
cd n8n-mcp

# 2. Install dependencies
npm install

# 3. Build TypeScript
npm run build

# 4. Initialize database
npm run rebuild

# 5. Validate installation
npm run validate

# 6. Run tests
npm test
```

---

## Post-Installation Setup

### Step 1: Verify Installation

```bash
# Check if all components work
npm run validate

# Expected output:
# ✓ Database loaded: 1,084 nodes
# ✓ All nodes validated successfully
```

### Step 2: Configure Claude Desktop (Optional)

**For macOS/Linux:**
```bash
# Edit Claude Desktop config
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**For Windows:**
```bash
# Edit Claude Desktop config
notepad %APPDATA%\Claude\claude_desktop_config.json
```

**Add n8n-mcp server:**
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "node",
      "args": ["/absolute/path/to/n8n-mcp/dist/mcp/index.js"],
      "env": {
        "DATABASE_PATH": "/absolute/path/to/n8n-mcp/data/nodes.db"
      }
    }
  }
}
```

**Important**: Replace `/absolute/path/to/n8n-mcp` with your actual installation path.

### Step 3: Configure n8n API (Optional)

If you want to create/update workflows in n8n:

```bash
# Create .env file
cp .env.example .env

# Edit .env
nano .env
```

**Add your n8n credentials:**
```bash
N8N_API_URL=https://your-n8n-instance.com
N8N_API_KEY=your-api-key-here
```

**Get your n8n API key:**
1. Go to your n8n instance
2. Settings → API
3. Create new API key
4. Copy and paste into .env

### Step 4: Test MCP Server

**Test in stdio mode:**
```bash
npm start
```

**Test in HTTP mode:**
```bash
npm run start:http
# Server starts on http://localhost:3000
```

**Test with sample query:**
```bash
# In another terminal
curl http://localhost:3000/health
# Should return: {"status":"ok","version":"2.33.2"}
```

---

## Quick Start: Build Your First Workflow

### 1. Search for Nodes

Using Claude Desktop with n8n-mcp installed:

```
Find me an HTTP Request node
```

Claude will use `search_nodes` to find relevant nodes.

### 2. Get Node Configuration

```
Show me how to configure the HTTP Request node
```

Claude will use `get_node` to retrieve detailed configuration.

### 3. Create a Simple Workflow

```
Create a workflow that:
1. Triggers on webhook (GET /hello)
2. Makes HTTP request to httpbin.org/get
3. Returns the response
```

Claude will:
- Use `search_nodes` to find Webhook and HTTP Request nodes
- Use `get_node` to get configuration details
- Use `validate_workflow` to ensure it's correct
- Optionally use `n8n_create_workflow` to deploy (if API configured)

### 4. Deploy to n8n

```
Deploy this workflow to my n8n instance
```

Claude will use `n8n_create_workflow` (requires N8N_API_URL and N8N_API_KEY).

---

## Troubleshooting

### Issue 1: `npm install` fails

**Error**: Dependencies won't install

**Solution**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

### Issue 2: `npm run build` fails

**Error**: TypeScript compilation errors

**Solution**:
```bash
# Install TypeScript globally
npm install -g typescript

# Clean build
rm -rf dist
npm run build
```

### Issue 3: Database not found

**Error**: `Cannot find database at data/nodes.db`

**Solution**:
```bash
# Rebuild database
npm run rebuild

# This takes 2-3 minutes - be patient
# Expected output: "✓ Successfully loaded 1,084 nodes"
```

### Issue 4: Claude Desktop doesn't see MCP server

**Error**: n8n-mcp tools not available in Claude

**Solution**:
1. Check `claude_desktop_config.json` has correct absolute paths
2. Restart Claude Desktop completely (Cmd+Q or Alt+F4)
3. Check Console for errors (Developer → Show Logs)
4. Verify `npm start` works in terminal first

### Issue 5: n8n API connection fails

**Error**: `n8n_create_workflow` returns 401 Unauthorized

**Solution**:
```bash
# Verify API key is correct
echo $N8N_API_KEY

# Test API connection
curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
  https://your-n8n-instance.com/api/v1/workflows

# Should return list of workflows (not 401 error)
```

---

## Verification Checklist

After installation, verify everything works:

- [ ] `node --version` shows v18+
- [ ] `npm --version` shows v9+
- [ ] `npm install` completes without errors
- [ ] `npm run build` completes successfully
- [ ] `npm run rebuild` loads 1,084 nodes
- [ ] `npm test` passes all tests
- [ ] `npm start` starts MCP server
- [ ] Claude Desktop config has correct paths
- [ ] Claude Desktop shows n8n-mcp tools (after restart)
- [ ] (Optional) n8n API connection works
- [ ] (Optional) Test workflow deploys successfully

---

## Next Steps

After successful installation:

1. **Read the Documentation**
   - `CLAUDE.md` - Complete project documentation
   - `QUICKSTART.md` - Quick start guide for workflow building
   - `MEMORY.md` - Key patterns and best practices

2. **Try the Test Workflow**
   ```bash
   # Deploy test workflow
   npm run test:templates
   ```

3. **Build Your First Workflow**
   - Open Claude Desktop
   - Ask: "Help me build an n8n workflow"
   - Follow Claude's guidance

4. **Explore the Ecosystem**
   - Install n8n-skills: `/plugin install czlonkowski/n8n-skills`
   - Read n8n-skills.com for usage guidance

---

## Environment Variables Reference

Create `.env` file with these optional variables:

```bash
# Core Configuration
MCP_MODE=stdio                    # or 'http'
DATABASE_PATH=./data/nodes.db     # SQLite path
LOG_LEVEL=error                   # error|warn|info|debug

# n8n API Integration (Optional)
N8N_API_URL=https://your.n8n.instance
N8N_API_KEY=your-api-key

# Community Nodes & AI Docs (Optional)
N8N_MCP_LLM_BASE_URL=http://localhost:1234/v1
N8N_MCP_LLM_MODEL=qwen3-4b-thinking-2507
N8N_MCP_LLM_TIMEOUT=60000

# Telemetry (Optional)
N8N_MCP_TELEMETRY_DISABLED=true   # Opt-out of telemetry

# HTTP Server (Optional)
N8N_MCP_PORT=3000
N8N_MCP_AUTH_TOKEN=your-token
N8N_MCP_MAX_SESSIONS=100
```

---

## Updating n8n-mcp

To update to the latest version:

```bash
# Pull latest changes
git pull origin main

# Reinstall dependencies
npm install

# Rebuild
npm run build

# Update database
npm run rebuild

# Restart MCP server (if running)
# Or restart Claude Desktop
```

---

## Uninstalling

To completely remove n8n-mcp:

```bash
# 1. Remove from Claude Desktop config
# Edit ~/Library/Application Support/Claude/claude_desktop_config.json
# Remove "n8n-mcp" section

# 2. Delete repository
cd ..
rm -rf n8n-mcp

# 3. Restart Claude Desktop
```

---

## Getting Help

### Documentation
- `CLAUDE.md` - Complete documentation (1,244 lines)
- `MEMORY.md` - Key patterns and decisions
- `LESSONS_LEARNED.md` - Common issues and solutions

### Community
- GitHub Issues: https://github.com/icojerrel/n8n-mcp/issues
- n8n Community: https://community.n8n.io

### Related Projects
- n8n-skills: https://github.com/czlonkowski/n8n-skills
- n8n Documentation: https://docs.n8n.io
- MCP Protocol: https://modelcontextprotocol.io

---

## License

MIT License - See LICENSE file for details

**Conceived by Romuald Członkowski** - https://www.aiadvisors.pl/en
