# n8n-mcp Installation Guide for Windows

Complete installation guide for Windows users.

**Version**: 2.33.2

---

## Prerequisites

1. **Node.js** (v18 or higher)
   - Download: https://nodejs.org
   - Check version:
     ```powershell
     node --version  # Should be v18.0.0 or higher
     ```

2. **npm** (comes with Node.js)
   ```powershell
   npm --version  # Should be v9.0.0 or higher
   ```

3. **Git**
   - Download: https://git-scm.com/download/win
   ```powershell
   git --version
   ```

---

## Installation Steps for Windows

### Step 1: Clone Repository (Already Done ✓)

You already cloned the repository. Navigate to it:

```powershell
cd n8n-mcp
```

### Step 2: Install Dependencies

```powershell
npm install --legacy-peer-deps
```

This will take a few minutes. You may see some warnings - that's normal.

### Step 3: Build TypeScript

```powershell
npm run build
```

### Step 4: Initialize Database

This takes 2-3 minutes to load 1,084 nodes:

```powershell
npm run rebuild:optimized
```

You should see:
```
✓ Successfully loaded 1,084 nodes
```

### Step 5: Validate Installation

```powershell
npm run validate
```

### Step 6: Test Installation

```powershell
npm test
```

---

## Configure Claude Desktop (Windows)

### Step 1: Find Claude Desktop Config

The config file is at:
```
%APPDATA%\Claude\claude_desktop_config.json
```

Open it with:
```powershell
notepad $env:APPDATA\Claude\claude_desktop_config.json
```

### Step 2: Get Absolute Path

First, get your current path:
```powershell
$currentPath = (Get-Location).Path
Write-Host "Your n8n-mcp path: $currentPath"
```

### Step 3: Edit Config

Replace the entire content with:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "node",
      "args": ["C:\\Users\\YourUsername\\path\\to\\n8n-mcp\\dist\\mcp\\index.js"],
      "env": {
        "DATABASE_PATH": "C:\\Users\\YourUsername\\path\\to\\n8n-mcp\\data\\nodes.db"
      }
    }
  }
}
```

**IMPORTANT**: Replace the paths with your actual paths from Step 2!

### Step 4: Restart Claude Desktop

Completely close and restart Claude Desktop (not just minimize).

---

## Configure n8n API (Optional)

### Step 1: Create .env File

```powershell
Copy-Item .env.example .env
```

### Step 2: Edit .env File

```powershell
notepad .env
```

Add your n8n credentials:
```
N8N_API_URL=https://your-n8n-instance.com
N8N_API_KEY=your-api-key-here
```

**Get API Key**: n8n → Settings → API → Create API Key

---

## Test the Installation

### Test 1: Start MCP Server

```powershell
npm start
```

You should see the MCP server start. Press Ctrl+C to stop.

### Test 2: Start HTTP Server

```powershell
npm run start:http
```

Open browser: http://localhost:3000/health

Should show: `{"status":"ok","version":"2.33.2"}`

Press Ctrl+C to stop.

### Test 3: Test in Claude Desktop

1. Open Claude Desktop
2. Start a new conversation
3. Type: "Search for HTTP Request nodes in n8n"
4. Claude should use the n8n-mcp tools

If tools don't appear, check:
- Config file has correct absolute paths (no forward slashes on Windows!)
- You restarted Claude Desktop
- `npm start` works without errors

---

## Verification Checklist

Run these commands to verify everything works:

```powershell
# 1. Check Node.js version
node --version  # Should be v18+

# 2. Check npm version
npm --version  # Should be v9+

# 3. Check if build exists
Test-Path dist\mcp\index.js  # Should return True

# 4. Check if database exists
Test-Path data\nodes.db  # Should return True

# 5. Check database size
(Get-Item data\nodes.db).Length / 1MB  # Should be ~50 MB

# 6. Test MCP server starts
npm start  # Should start without errors (Ctrl+C to stop)
```

---

## Troubleshooting Windows Issues

### Issue 1: npm install fails with peer dependency errors

**Solution**:
```powershell
# Clear cache
npm cache clean --force

# Remove old installation
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json

# Reinstall with legacy peer deps
npm install --legacy-peer-deps
```

### Issue 2: PowerShell execution policy error

**Error**: "cannot be loaded because running scripts is disabled"

**Solution**:
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 3: Long path names error

**Error**: "ENAMETOOLONG" or path too long

**Solution**:
```powershell
# Enable long paths (requires Admin)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1
```

Then restart and reinstall.

### Issue 4: Node version too old

Check version:
```powershell
node --version
```

If < v18, download and install from: https://nodejs.org

### Issue 5: Claude Desktop doesn't see MCP server

**Common mistakes:**
- Using forward slashes `/` instead of backslashes `\` in Windows paths
- Not using absolute paths
- Not restarting Claude Desktop

**Fix**:
```powershell
# Get correct path
$currentPath = (Get-Location).Path
$distPath = "$currentPath\dist\mcp\index.js"
$dbPath = "$currentPath\data\nodes.db"

Write-Host "Use these paths in Claude Desktop config:"
Write-Host "args: [`"$distPath`"]"
Write-Host "DATABASE_PATH: `"$dbPath`""
```

Copy the output into your Claude Desktop config.

---

## Windows-Specific Tips

### Use PowerShell (Not CMD)

All commands should be run in PowerShell, not Command Prompt.

### Path Separators

Windows uses backslashes `\`, not forward slashes `/`:
- ✅ Correct: `C:\Users\YourName\n8n-mcp`
- ❌ Wrong: `C:/Users/YourName/n8n-mcp`

### Absolute Paths Required

Claude Desktop config needs full absolute paths:
- ✅ Correct: `C:\Users\YourName\n8n-mcp\dist\mcp\index.js`
- ❌ Wrong: `./dist/mcp/index.js`

### Environment Variables

Access with `$env:`:
```powershell
$env:N8N_API_URL
$env:APPDATA
```

---

## Quick Start After Installation

1. **Open Claude Desktop**

2. **Ask Claude**:
   ```
   Search for nodes related to HTTP requests
   ```

3. **Build a workflow**:
   ```
   Create an n8n workflow that:
   - Triggers on webhook GET /hello
   - Makes HTTP request to httpbin.org/get
   - Returns the response
   ```

4. **See the magic!** ✨

---

## Next Steps

1. ✅ Installation complete
2. Read `QUICKSTART.md` for workflow patterns
3. Read `CLAUDE.md` for complete documentation
4. Install n8n-skills: `/plugin install czlonkowski/n8n-skills` in Claude Code

---

## Getting Help

- `INSTALL.md` - General installation guide
- `QUICKSTART.md` - 5-minute quick start
- `CLAUDE.md` - Complete documentation
- GitHub Issues: https://github.com/icojerrel/n8n-mcp/issues

---

**You're ready to build n8n workflows on Windows!** 🎉

**Conceived by Romuald Członkowski** - https://www.aiadvisors.pl/en
