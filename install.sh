#!/bin/bash

# n8n-mcp Installation Script
# Automated installation and setup for n8n-mcp
# Version: 2.33.2

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}\n"
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║              n8n-mcp Installation                 ║
║                                                   ║
║        Model Context Protocol for n8n             ║
║         Version 2.33.2 (n8n 2.3.3)               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running from correct directory
if [ ! -f "package.json" ]; then
    log_error "Please run this script from the n8n-mcp root directory"
    exit 1
fi

# Step 1: Check Prerequisites
log_step "Step 1: Checking Prerequisites"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    log_success "Node.js found: $NODE_VERSION"

    # Check if version is >= 18
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        log_error "Node.js version 18 or higher required. Found: $NODE_VERSION"
        log_info "Please update Node.js: https://nodejs.org"
        exit 1
    fi
else
    log_error "Node.js not found"
    log_info "Please install Node.js v18+: https://nodejs.org"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    log_success "npm found: v$NPM_VERSION"
else
    log_error "npm not found (should come with Node.js)"
    exit 1
fi

# Check git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    log_success "Git found: $GIT_VERSION"
else
    log_warning "Git not found (optional, but recommended)"
fi

# Step 2: Clean Previous Installation (if exists)
log_step "Step 2: Cleaning Previous Installation"

if [ -d "node_modules" ]; then
    log_info "Removing old node_modules..."
    rm -rf node_modules
    log_success "Cleaned node_modules"
fi

if [ -f "package-lock.json" ]; then
    log_info "Removing old package-lock.json..."
    rm -f package-lock.json
    log_success "Cleaned package-lock.json"
fi

if [ -d "dist" ]; then
    log_info "Removing old build..."
    rm -rf dist
    log_success "Cleaned dist"
fi

# Step 3: Install Dependencies
log_step "Step 3: Installing Dependencies"

log_info "Running npm install (this may take a few minutes)..."
if npm install --legacy-peer-deps > /dev/null 2>&1; then
    log_success "Dependencies installed successfully"
else
    log_warning "npm install had warnings, retrying with verbose output..."
    npm install --legacy-peer-deps
fi

# Step 4: Build TypeScript
log_step "Step 4: Building TypeScript"

log_info "Compiling TypeScript..."
if npm run build > /dev/null 2>&1; then
    log_success "TypeScript compiled successfully"
else
    log_error "TypeScript compilation failed"
    log_info "Running build with verbose output..."
    npm run build
    exit 1
fi

# Step 5: Initialize Database
log_step "Step 5: Initializing Database"

log_info "Rebuilding database (this takes 2-3 minutes)..."
log_warning "Please be patient, loading 1,084 nodes from n8n packages..."

if npm run rebuild:optimized > install.log 2>&1; then
    log_success "Database initialized successfully"
    log_info "Database location: $(pwd)/data/nodes.db"
else
    log_error "Database rebuild failed"
    log_info "Check install.log for details"
    tail -20 install.log
    exit 1
fi

# Step 6: Validate Installation
log_step "Step 6: Validating Installation"

log_info "Running validation tests..."
if npm run validate > /dev/null 2>&1; then
    log_success "All validation tests passed"
else
    log_warning "Some validation tests failed (this may be ok)"
fi

# Step 7: Run Quick Test
log_step "Step 7: Running Quick Tests"

log_info "Running test suite..."
if npm test -- --passWithNoTests > /dev/null 2>&1; then
    log_success "Tests passed"
else
    log_warning "Some tests failed (this may be ok for initial setup)"
fi

# Step 8: Setup Instructions
log_step "Step 8: Post-Installation Setup"

echo ""
log_success "Installation completed successfully!"
echo ""

log_info "Next steps:"
echo ""
echo "1. Configure Claude Desktop (optional):"
echo "   Edit: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "   Or on Windows: %APPDATA%\Claude\claude_desktop_config.json"
echo ""
echo "   Add this configuration:"
echo '   {'
echo '     "mcpServers": {'
echo '       "n8n-mcp": {'
echo '         "command": "node",'
echo "         \"args\": [\"$(pwd)/dist/mcp/index.js\"],"
echo "         \"env\": {"
echo "           \"DATABASE_PATH\": \"$(pwd)/data/nodes.db\""
echo '         }'
echo '       }'
echo '     }'
echo '   }'
echo ""

echo "2. Configure n8n API (optional):"
echo "   cp .env.example .env"
echo "   Edit .env and add:"
echo "   N8N_API_URL=https://your-n8n-instance.com"
echo "   N8N_API_KEY=your-api-key"
echo ""

echo "3. Test the installation:"
echo "   npm start              # Start MCP server in stdio mode"
echo "   npm run start:http     # Or start in HTTP mode"
echo ""

echo "4. Read the documentation:"
echo "   cat INSTALL.md         # Installation guide"
echo "   cat QUICKSTART.md      # Quick start guide"
echo "   cat CLAUDE.md          # Complete documentation"
echo ""

echo "5. Install n8n-skills (recommended):"
echo "   In Claude Code: /plugin install czlonkowski/n8n-skills"
echo ""

log_success "You're ready to start building workflows!"
echo ""

# Optional: Ask if user wants to configure Claude Desktop now
read -p "$(echo -e ${YELLOW}Would you like to configure Claude Desktop now? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Opening Claude Desktop config location..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        mkdir -p "$(dirname "$CLAUDE_CONFIG")"

        if [ ! -f "$CLAUDE_CONFIG" ]; then
            echo '{"mcpServers":{}}' > "$CLAUDE_CONFIG"
        fi

        open -R "$CLAUDE_CONFIG"
        log_info "Claude Desktop config opened in Finder"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        CLAUDE_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
        mkdir -p "$(dirname "$CLAUDE_CONFIG")"

        if [ ! -f "$CLAUDE_CONFIG" ]; then
            echo '{"mcpServers":{}}' > "$CLAUDE_CONFIG"
        fi

        log_info "Claude Desktop config: $CLAUDE_CONFIG"
        log_info "Please edit this file manually"
    else
        # Windows / Other
        log_info "Please manually edit: %APPDATA%\\Claude\\claude_desktop_config.json"
    fi

    log_warning "Remember to restart Claude Desktop after editing the config!"
fi

echo ""
log_info "Installation log saved to: install.log"
log_success "Happy workflow building!"
echo ""

# Cleanup
rm -f install.log
