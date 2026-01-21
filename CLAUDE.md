# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

n8n-mcp is a comprehensive documentation and knowledge server that provides AI assistants with complete access to n8n node information through the Model Context Protocol (MCP). It serves as a bridge between n8n's workflow automation platform and AI models, enabling them to understand and work with n8n nodes effectively.

**Current Version**: 2.33.2 (n8n 2.3.3)

**Coverage Stats**:
- 1,084 n8n nodes (537 core + 547 community, including 301 verified)
- 99% property coverage with detailed schemas
- 87% documentation coverage from official n8n docs
- 2,709 workflow templates with 100% metadata coverage
- 265 AI-capable tool variants detected

### Current Architecture:
```
src/
├── loaders/
│   └── node-loader.ts         # NPM package loader for core and AI nodes
├── parsers/
│   ├── node-parser.ts         # Enhanced parser with version support
│   ├── property-extractor.ts  # Dedicated property/operation extraction
│   └── simple-parser.ts       # Lightweight parser for quick operations
├── mappers/
│   └── docs-mapper.ts         # Documentation mapping with fixes
├── database/
│   ├── schema.sql             # SQLite schema with FTS5 search
│   ├── node-repository.ts     # Data access layer
│   ├── database-adapter.ts    # Universal database adapter (better-sqlite3/sql.js)
│   └── migrations/            # Database migration scripts
├── community/                  # Community nodes support (v2.32.0+)
│   ├── community-node-fetcher.ts       # Fetch from Strapi API & npm registry
│   ├── community-node-service.ts       # Business logic for community nodes
│   ├── documentation-generator.ts      # AI-powered docs (LLM integration)
│   ├── documentation-batch-processor.ts # Batch processing with progress
│   └── index.ts
├── services/                   # Business logic layer
│   ├── property-filter.ts     # Filters properties to AI-friendly essentials
│   ├── example-generator.ts   # Generates working examples
│   ├── task-templates.ts      # Pre-configured node settings
│   ├── config-validator.ts    # Multi-profile validation system
│   ├── enhanced-config-validator.ts    # Operation-aware validation
│   ├── node-specific-validators.ts     # Node-specific validation logic
│   ├── property-dependencies.ts        # Dependency analysis
│   ├── type-structure-service.ts       # Complex type validation
│   ├── expression-validator.ts         # n8n expression syntax validation
│   ├── universal-expression-validator.ts # Enhanced expression validation
│   ├── workflow-validator.ts           # Complete workflow validation
│   ├── workflow-auto-fixer.ts          # Automatic workflow repair
│   ├── workflow-diff-engine.ts         # Diff-based workflow updates
│   ├── workflow-versioning-service.ts  # Version tracking
│   ├── node-migration-service.ts       # Node version migrations
│   ├── node-similarity-service.ts      # Find similar nodes
│   ├── operation-similarity-service.ts # Find similar operations
│   ├── resource-similarity-service.ts  # Find similar resources
│   ├── node-documentation-service.ts   # Documentation retrieval
│   ├── n8n-api-client.ts              # n8n API client
│   ├── n8n-validation.ts              # n8n-specific validation
│   ├── ai-node-validator.ts           # AI/LangChain node validation
│   ├── ai-tool-validators.ts          # AI Tool variant validation
│   ├── breaking-change-detector.ts    # Detect breaking changes
│   ├── breaking-changes-registry.ts   # Known breaking changes
│   └── sqlite-storage-service.ts      # SQLite storage abstraction
├── triggers/                   # Workflow trigger system (v2.30+)
│   ├── trigger-detector.ts    # Auto-detect trigger types
│   ├── trigger-registry.ts    # Handler registry
│   ├── types.ts               # Trigger type definitions
│   └── handlers/
│       ├── base-handler.ts    # Base trigger handler
│       ├── webhook-handler.ts # HTTP webhook triggers
│       ├── form-handler.ts    # n8n Form triggers
│       └── chat-handler.ts    # AI Agent Chat triggers
├── telemetry/                  # Anonymous usage analytics (v2.31+)
│   ├── telemetry-manager.ts   # Main telemetry controller
│   ├── config-manager.ts      # Configuration & opt-out
│   ├── event-tracker.ts       # Event collection
│   ├── mutation-tracker.ts    # Track workflow mutations
│   ├── performance-monitor.ts # Performance metrics
│   ├── workflow-sanitizer.ts  # Remove sensitive data
│   └── index.ts
├── n8n/                        # n8n native integration (v2.30+)
│   ├── MCPNode.node.ts        # n8n node for MCP operations
│   └── MCPApi.credentials.ts  # Credential type for MCP API
├── types/
│   ├── type-structures.ts     # Type structure definitions
│   ├── instance-context.ts    # Multi-tenant instance configuration
│   ├── session-state.ts       # Session persistence types
│   ├── workflow-diff.ts       # Workflow diff types
│   ├── n8n-api.ts             # n8n API types
│   └── node-types.ts          # Extended node type definitions
├── constants/
│   └── type-structures.ts     # 22 complete type structures
├── templates/                  # Workflow template system
│   ├── template-fetcher.ts    # Fetches from n8n.io API
│   ├── template-repository.ts # Database operations
│   └── template-service.ts    # Business logic
├── scripts/                    # CLI utilities
│   ├── rebuild.ts             # Database rebuild
│   ├── rebuild-optimized.ts   # Optimized rebuild
│   ├── validate.ts            # Node validation
│   ├── fetch-templates.ts     # Fetch workflow templates
│   ├── fetch-community-nodes.ts # Fetch community nodes
│   ├── generate-community-docs.ts # AI doc generation
│   ├── test-*.ts              # Various test scripts
│   └── sanitize-templates.ts  # Template sanitization
├── mcp/                        # MCP Protocol implementation
│   ├── server.ts              # Main MCP server
│   ├── tools.ts               # Documentation tools
│   ├── tools-n8n-manager.ts   # n8n workflow management tools
│   ├── tools-documentation.ts # Tool documentation system
│   ├── handlers-workflow-diff.ts # Workflow diff handlers
│   ├── handlers-n8n-manager.ts   # n8n API handlers
│   ├── stdio-wrapper.ts       # stdio mode wrapper
│   ├── index.ts               # Entry point with mode selection
│   └── tool-docs/             # Structured tool documentation
│       ├── discovery/
│       ├── configuration/
│       ├── validation/
│       ├── workflow_management/
│       ├── templates/
│       ├── guides/
│       └── system/
├── utils/                      # Shared utilities
│   ├── console-manager.ts     # Console output isolation
│   ├── logger.ts              # Logging utility
│   ├── auth.ts                # Authentication helpers
│   ├── error-handler.ts       # Error handling
│   ├── validation-schemas.ts  # Zod validation schemas
│   ├── expression-utils.ts    # Expression parsing
│   ├── node-utils.ts          # Node manipulation
│   └── ...                    # Various other utilities
├── errors/                     # Custom error types
│   └── validation-service-error.ts
├── config/                     # Configuration management
│   └── ...
├── http-server-single-session.ts # Single-session HTTP server
├── mcp-engine.ts              # Clean API for service integration
└── index.ts                   # Library exports
```

## Common Development Commands

```bash
# Build and Setup
npm run build          # Build TypeScript (always run after changes)
npm run rebuild        # Rebuild node database from n8n packages
npm run rebuild:optimized # Optimized rebuild (faster)
npm run validate       # Validate all node data in database

# Testing
npm test               # Run all tests
npm run test:unit      # Run unit tests only
npm run test:integration # Run integration tests
npm run test:integration:n8n # Test n8n API integration
npm run test:coverage  # Run tests with coverage report
npm run test:watch     # Run tests in watch mode
npm run test:ci        # CI mode with junit reporter
npm run test:e2e       # End-to-end tests

# Specialized Testing
npm run test:structure-validation # Test type structure validation
npm run test:workflow-validation  # Test workflow validation
npm run test:ai-workflow-validation # Test AI workflow validation
npm run test:mcp-tools # Test MCP tool enhancements
npm run test:n8n-validate-workflow # Test n8n_validate_workflow tool
npm run test:workflow-diff # Test workflow diff engine
npm run test:tools-documentation # Test tool documentation system
npm run test:templates # Test template functionality
npm run test:essentials # Test node essentials tools
npm run test:enhanced-validation # Test enhanced validation

# Run a single test file
npm test -- tests/unit/services/property-filter.test.ts

# Linting and Type Checking
npm run lint           # Check TypeScript types (alias for typecheck)
npm run typecheck      # Check TypeScript types

# Running the Server
npm start              # Start MCP server in stdio mode
npm run start:http     # Start MCP server in HTTP mode
npm run start:n8n      # Start in n8n integration mode
npm run dev            # Build, rebuild database, and validate
npm run dev:http       # Run HTTP server with auto-reload

# Update n8n Dependencies
npm run update:n8n:check  # Check for n8n updates (dry run)
npm run update:n8n        # Update n8n packages to latest

# Database Management
npm run db:rebuild     # Rebuild database from scratch
npm run db:init        # Initialize empty database
npm run migrate:fts5   # Migrate to FTS5 search (if needed)

# Template Management
npm run fetch:templates        # Fetch latest workflow templates from n8n.io
npm run fetch:templates:update # Update existing templates
npm run fetch:templates:robust # Robust fetching with retries
npm run sanitize:templates     # Sanitize template data
npm run test:templates         # Test template functionality

# Community Nodes Management
npm run fetch:community              # Fetch all community nodes (verified + top npm)
npm run fetch:community:verified     # Fetch verified community nodes only
npm run fetch:community:update       # Incremental update (skip existing)

# AI Documentation Generation
npm run generate:docs              # Full generation (README + AI summary)
npm run generate:docs:readme-only  # Only fetch READMEs from npm
npm run generate:docs:summary-only # Only generate AI summaries
npm run generate:docs:incremental  # Skip nodes with existing data
npm run generate:docs:stats        # Show documentation statistics
npm run migrate:readme-columns     # Migrate database schema for AI docs

# Benchmarking
npm run benchmark       # Run benchmarks
npm run benchmark:watch # Run benchmarks in watch mode
npm run benchmark:ui    # Run benchmarks with UI
npm run benchmark:ci    # CI benchmark mode

# Release Management
npm run sync:runtime-version # Sync package.runtime.json version
npm run update:readme-version # Update README version badge
npm run prepare:publish      # Prepare for npm publish
npm run prepare:release      # Prepare release artifacts
npm run update:all           # Update and prepare for publish
```

## High-Level Architecture

### Core Components

1. **MCP Server** (`mcp/server.ts`)
   - Implements Model Context Protocol for AI assistants
   - 18 comprehensive tools for n8n workflow automation
   - Supports both stdio (Claude Desktop) and HTTP modes
   - Built-in tool documentation system

2. **Database Layer** (`database/`)
   - SQLite database storing 1,084+ n8n nodes
   - Universal adapter pattern supporting both better-sqlite3 and sql.js
   - Full-text search capabilities with FTS5
   - Schema migrations for version upgrades

3. **Node Processing Pipeline**
   - **Loader** (`loaders/node-loader.ts`): Loads nodes from n8n packages
   - **Parser** (`parsers/node-parser.ts`): Extracts node metadata and structure
   - **Property Extractor** (`parsers/property-extractor.ts`): Deep property analysis
   - **Docs Mapper** (`mappers/docs-mapper.ts`): Maps external documentation

4. **Community Nodes System** (`community/`) - NEW in v2.32+
   - **Community Node Fetcher**: Fetches from Strapi API and npm registry
   - **Community Node Service**: Business logic for 547 community nodes (301 verified)
   - **Documentation Generator**: AI-powered docs using local LLM (Qwen)
   - **Batch Processor**: Efficient bulk documentation generation

5. **Service Layer** (`services/`)
   - **Property Filter**: Reduces node properties to AI-friendly essentials
   - **Config Validator**: Multi-profile validation system
   - **Type Structure Service**: Validates complex type structures
   - **Expression Validator**: Validates n8n expression syntax
   - **Workflow Validator**: Complete workflow structure validation
   - **Workflow Auto-Fixer**: Automatic workflow repair
   - **Workflow Diff Engine**: Efficient diff-based updates (80-90% token savings)
   - **Node Migration Service**: Handles version migrations
   - **Similarity Services**: Find similar nodes/operations/resources
   - **AI Node Validator**: Specialized AI/LangChain validation

6. **Trigger System** (`triggers/`) - NEW in v2.30+
   - **Trigger Detector**: Auto-detect workflow trigger types
   - **Webhook Handler**: HTTP webhook triggers
   - **Form Handler**: n8n Form triggers
   - **Chat Handler**: AI Agent Chat triggers
   - Enables workflow testing via `n8n_test_workflow` tool

7. **Telemetry System** (`telemetry/`) - NEW in v2.31+
   - **Telemetry Manager**: Anonymous usage analytics
   - **Event Tracker**: Track tool usage and performance
   - **Mutation Tracker**: Monitor workflow changes
   - **Workflow Sanitizer**: Remove sensitive data before tracking
   - Opt-out supported via `N8N_MCP_TELEMETRY_DISABLED=true`

8. **Template System** (`templates/`)
   - Fetches and stores 2,709 workflow templates from n8n.io
   - Provides pre-built workflow examples
   - Supports template search and validation

9. **n8n Native Integration** (`n8n/`) - NEW in v2.30+
   - **MCPNode.node.ts**: n8n node for MCP operations
   - **MCPApi.credentials.ts**: Credential type for MCP API
   - Enables n8n → MCP → n8n recursive workflows

### Key Design Patterns

1. **Repository Pattern**: All database operations go through repository classes
2. **Service Layer**: Business logic separated from data access
3. **Validation Profiles**: Different validation strictness levels (minimal, runtime, ai-friendly, strict)
4. **Diff-Based Updates**: Efficient workflow updates using operation diffs
5. **Handler Pattern**: Extensible trigger handler system
6. **Universal Adapter**: Database adapter works in Node.js and browser (sql.js)

### MCP Tools Architecture

The MCP server exposes 18 tools in several categories:

1. **System Tools**
   - `tools_documentation`: Get tool usage documentation

2. **Discovery Tools**
   - `search_nodes`: Search 1,084 nodes with optional examples
   - `search_templates`: Search 2,709 workflow templates

3. **Configuration Tools**
   - `get_node`: Get node details (info/docs/search_properties/versions)
   - `get_template`: Get template details

4. **Validation Tools**
   - `validate_node`: Validate single node configuration
   - `validate_workflow`: Validate complete workflow
   - `n8n_validate_workflow`: Validate workflow with n8n API

5. **Workflow Management Tools** (requires n8n API)
   - `n8n_create_workflow`: Create new workflow
   - `n8n_get_workflow`: Retrieve workflow
   - `n8n_list_workflows`: List all workflows
   - `n8n_update_full_workflow`: Full workflow replacement
   - `n8n_update_partial_workflow`: Diff-based partial update
   - `n8n_delete_workflow`: Delete workflow
   - `n8n_autofix_workflow`: Auto-repair workflow issues
   - `n8n_test_workflow`: Execute workflow via trigger
   - `n8n_executions`: Get workflow execution history
   - `n8n_workflow_versions`: Get workflow version history
   - `n8n_deploy_template`: Deploy template to n8n instance
   - `n8n_health_check`: Check n8n API connectivity

## MCP Tools Reference

### Tool Selection Guide

**For discovering nodes:**
- `search_nodes`: Search by keyword (supports OR/AND/FUZZY modes)
  - Use `source` filter: `all`, `core`, `community`, `verified`
  - Set `includeExamples=true` for real-world template configs

**For node details:**
- `get_node`: Get comprehensive node information
  - `detail`: `minimal` (~200 tokens), `standard` (~1-2K), `full` (~3-8K)
  - `mode`: `info` (schema), `docs` (markdown), `search_properties`, `versions`

**For validation:**
- `validate_node`: Quick single-node validation
- `validate_workflow`: Complete workflow validation (offline)
- `n8n_validate_workflow`: Validate with real n8n API (requires API key)

**For workflow operations:**
- `n8n_create_workflow`: Create new workflow
- `n8n_update_partial_workflow`: Efficient diff-based updates (recommended)
- `n8n_update_full_workflow`: Full replacement (use sparingly)
- `n8n_autofix_workflow`: Auto-repair common issues
- `n8n_test_workflow`: Execute workflow via webhook/form/chat trigger

**For templates:**
- `search_templates`: Search 2,709 pre-built workflows
- `get_template`: Get template details
- `n8n_deploy_template`: Deploy template to n8n instance

### Important Tool Usage Notes

1. **Always validate before deploying**: Use `validate_workflow` or `n8n_validate_workflow` before creating/updating workflows
2. **Use partial updates**: `n8n_update_partial_workflow` is 80-90% more efficient than full updates
3. **Check tool documentation**: Use `tools_documentation` for detailed usage guides
4. **Community nodes**: Filter by `source='verified'` for production use
5. **Auto-fix capability**: `n8n_autofix_workflow` can repair many common issues automatically

## Memories and Notes for Development

### Development Workflow Reminders
- When you make changes to MCP server, you need to ask the user to reload it before you test
- When the user asks to review issues, you should use GH CLI to get the issue and all the comments
- When the task can be divided into separated subtasks, you should spawn separate sub-agents to handle them in parallel
- Use the best sub-agent for the task as per their descriptions

### Testing Best Practices
- Always run `npm run build` before testing changes
- Use `npm run dev` to rebuild database after package updates
- Check coverage with `npm run test:coverage`
- Integration tests require a clean database state
- Test n8n API integration with `npm run test:integration:n8n`
- Run specialized tests for specific features (workflow-diff, ai-validation, etc.)

### Common Pitfalls
- The MCP server needs to be reloaded in Claude Desktop after changes
- HTTP mode requires proper CORS and auth token configuration
- Database rebuilds can take 2-3 minutes due to n8n package size (use `rebuild:optimized` for faster builds)
- Always validate workflows before deployment to n8n
- Community node names are lowercase (e.g., `chatwoot` not `Chatwoot`)
- Dynamic AI Tool nodes (e.g., `googleDriveTool`) are inferred at validation time

### Performance Considerations
- Use `detail='minimal'` or `detail='standard'` in `get_node` for faster responses
- Batch validation operations when possible
- The diff-based update system saves 80-90% tokens on workflow updates
- Use `includeExamples=false` in `search_nodes` when examples aren't needed
- FTS5 full-text search is optimized for large result sets

### Agent Interaction Guidelines
- Sub-agents are not allowed to spawn further sub-agents
- When you use sub-agents, do not allow them to commit and push. That should be done by you

### Development Best Practices
- Run typecheck and lint after every code change
- Use appropriate validation profiles (minimal/runtime/ai-friendly/strict)
- Follow the repository pattern for database access
- Keep services stateless and testable

### Community Nodes Support (v2.32.0+)

**Location:**
- Service: `src/community/community-node-service.ts`
- Fetcher: `src/community/community-node-fetcher.ts`
- AI Docs: `src/community/documentation-generator.ts`
- Batch Processing: `src/community/documentation-batch-processor.ts`
- CLI: `src/scripts/fetch-community-nodes.ts`, `src/scripts/generate-community-docs.ts`

**Key Features:**
- **547 community nodes** indexed (301 verified + 246 popular npm packages)
- **Source filtering**: Search by `all`, `core`, `community`, or `verified`
- **Community metadata**: `isCommunity`, `isVerified`, `authorName`, `npmDownloads`
- **Full schema support**: Verified nodes work seamlessly with all MCP tools
- **AI-powered documentation**: 537/547 nodes have AI-generated summaries

**Data Sources:**
- Verified nodes: Fetched from n8n Strapi API (`api.n8n.io/api/community-nodes`)
- Popular nodes: Fetched from npm registry (keyword: `n8n-community-node-package`)
- README content: Fetched from npm registry for all nodes
- AI summaries: Generated using local LLM (Qwen or compatible)

**CLI Commands:**
```bash
# Fetch community nodes
npm run fetch:community              # Full rebuild (verified + top 100 npm)
npm run fetch:community:verified     # Verified nodes only (fast)
npm run fetch:community:update       # Incremental update (skip existing)

# Generate AI documentation
npm run generate:docs              # Full generation (README + AI summary)
npm run generate:docs:readme-only  # Only fetch READMEs from npm
npm run generate:docs:summary-only # Only generate AI summaries
npm run generate:docs:incremental  # Skip nodes with existing data
npm run generate:docs:stats        # Show documentation statistics
```

**Environment Variables:**
```bash
N8N_MCP_LLM_BASE_URL=http://localhost:1234/v1  # LLM server URL
N8N_MCP_LLM_MODEL=qwen3-4b-thinking-2507       # Model name
N8N_MCP_LLM_TIMEOUT=60000                       # Request timeout (ms)
```

**AI Documentation Structure:**
The AI generates structured summaries with:
- Purpose: What the node does
- Capabilities: Key features
- Authentication: Required credentials
- Common use cases: Practical examples
- Limitations: Known caveats
- Related nodes: Similar n8n nodes

**Important Notes:**
- Community node names are lowercase (e.g., `chatwoot` not `Chatwoot`)
- Verified nodes have full schema information
- Non-verified nodes may have limited property data
- AI summaries require local LLM setup (OpenAI-compatible API)

### Trigger System (v2.30.0+)

**Location:**
- Detector: `src/triggers/trigger-detector.ts`
- Registry: `src/triggers/trigger-registry.ts`
- Types: `src/triggers/types.ts`
- Handlers: `src/triggers/handlers/`

**Purpose:**
Enables workflow execution through the `n8n_test_workflow` MCP tool by detecting and invoking workflow triggers.

**Supported Trigger Types:**
1. **Webhook** (`@n8n/n8n-nodes-langchain.webhook`)
   - HTTP-based triggers
   - Supports GET, POST, PUT, DELETE methods
   - Can pass custom headers and body data
   - Auto-detects webhook path from node config

2. **Form** (`@n8n/n8n-nodes-langchain.formTrigger`)
   - n8n Form triggers
   - Supports passing form field values
   - Auto-detects form configuration

3. **Chat** (`@n8n/n8n-nodes-langchain.chatTrigger`)
   - AI Agent Chat triggers
   - Requires `message` parameter
   - Optional `sessionId` for conversation context
   - Synchronous mode only

**How It Works:**
1. `TriggerDetector` analyzes workflow nodes to find trigger types
2. `TriggerRegistry` routes to appropriate handler
3. Handler constructs correct API request for trigger type
4. Returns execution result with metadata

**Usage Example:**
```typescript
// Auto-detect trigger type
n8n_test_workflow({
  workflowId: "abc123"
})

// Explicit webhook trigger
n8n_test_workflow({
  workflowId: "abc123",
  triggerType: "webhook",
  data: { name: "Test User" },
  headers: { "X-Custom": "value" }
})

// Chat trigger
n8n_test_workflow({
  workflowId: "abc123",
  triggerType: "chat",
  message: "Hello, assistant!",
  sessionId: "user-123"
})
```

**Important Notes:**
- Workflows must be **active** for triggers to work
- Direct API execution (without triggers) is not supported by n8n
- Webhook paths are auto-detected from node configuration
- Chat triggers only work in synchronous response mode

### Telemetry System (v2.31.0+)

**Location:**
- Manager: `src/telemetry/telemetry-manager.ts`
- Config: `src/telemetry/config-manager.ts`
- Event Tracking: `src/telemetry/event-tracker.ts`
- Mutation Tracking: `src/telemetry/mutation-tracker.ts`
- Sanitization: `src/telemetry/workflow-sanitizer.ts`

**Purpose:**
Anonymous usage analytics to improve n8n-mcp. All data is sanitized to remove sensitive information.

**What Gets Tracked:**
- Tool usage frequency and patterns
- Performance metrics (response times, error rates)
- Workflow mutations (node additions, property changes)
- Feature adoption (community nodes, AI tools, etc.)

**Privacy Features:**
- **Workflow sanitization**: Removes all user data, credentials, URLs
- **Anonymous IDs**: No personally identifiable information
- **Opt-out supported**: Set `N8N_MCP_TELEMETRY_DISABLED=true`
- **Local-first**: Events batched and sent periodically

**Environment Variables:**
```bash
N8N_MCP_TELEMETRY_DISABLED=true     # Disable telemetry
N8N_MCP_TELEMETRY_DEBUG=true        # Enable telemetry debug logs
N8N_MCP_TELEMETRY_ENDPOINT=<url>    # Custom telemetry endpoint
```

**What Is NOT Tracked:**
- Workflow data or content
- User credentials or API keys
- Personal information
- Workflow names or descriptions
- n8n instance URLs or IDs

**Components:**
- **TelemetryManager**: Main controller
- **EventTracker**: Collects tool usage events
- **MutationTracker**: Tracks workflow changes
- **PerformanceMonitor**: Measures response times
- **WorkflowSanitizer**: Removes sensitive data
- **ConfigManager**: Handles opt-out and settings

### n8n Native Integration (v2.30.0+)

**Location:**
- Node: `src/n8n/MCPNode.node.ts`
- Credentials: `src/n8n/MCPApi.credentials.ts`

**Purpose:**
Enables using n8n-mcp as a node within n8n workflows, creating recursive n8n → MCP → n8n capabilities.

**Features:**
- **MCPNode**: n8n node that can call any MCP tool
- **MCPApi Credentials**: Credential type for MCP API authentication
- Supports all 18 MCP tools within n8n workflows
- Enables workflow generation workflows (AI creates workflows in n8n)

**Use Cases:**
- AI-powered workflow builders within n8n
- Dynamic workflow modification based on conditions
- Self-improving workflows that optimize themselves
- Integration with n8n's visual workflow builder

**Important Notes:**
- This creates powerful recursive capabilities
- Use with caution in production environments
- Consider rate limiting and validation
- Circular dependencies are possible - design carefully

### Session Persistence Feature (v2.24.1)

**Location:**
- Types: `src/types/session-state.ts`
- Implementation: `src/http-server-single-session.ts` (lines 698-702, 1444-1584)
- Wrapper: `src/mcp-engine.ts` (lines 123-169)
- Tests: `tests/unit/http-server/session-persistence.test.ts`, `tests/unit/mcp-engine/session-persistence.test.ts`

**Key Features:**
- **Export/Restore API**: `exportSessionState()` and `restoreSessionState()` methods
- **Multi-tenant support**: Enables zero-downtime deployments for SaaS platforms
- **Security-first**: API keys exported as plaintext - downstream MUST encrypt
- **Dormant sessions**: Restored sessions recreate transports on first request
- **Automatic expiration**: Respects `sessionTimeout` setting (default 30 min)
- **MAX_SESSIONS limit**: Caps at 100 concurrent sessions (configurable via N8N_MCP_MAX_SESSIONS env var)

**Important Implementation Notes:**
- Only exports sessions with valid n8nApiUrl and n8nApiKey in context
- Skips expired sessions during both export and restore
- Uses `validateInstanceContext()` for data integrity checks
- Handles null/invalid session gracefully with warnings
- Session metadata (timestamps) and context (credentials) are persisted
- Transport and server objects are NOT persisted (recreated on-demand)

**Testing:**
- 22 unit tests covering export, restore, edge cases, and round-trip cycles
- Tests use current timestamps to avoid expiration issues
- Integration with multi-tenant backends documented in README.md

### Workflow Diff Engine (v2.7.0+)

**Location:**
- Engine: `src/services/workflow-diff-engine.ts`
- Handler: `src/mcp/handlers-workflow-diff.ts`
- Types: `src/types/workflow-diff.ts`
- Tool: `n8n_update_partial_workflow` in `src/mcp/tools-n8n-manager.ts`

**Purpose:**
Enables efficient workflow updates by computing and applying minimal diffs instead of replacing entire workflows.

**Key Benefits:**
- **80-90% token savings**: Only send changed properties, not entire workflow
- **Atomic operations**: Changes applied as transactions
- **Conflict detection**: Detects concurrent modifications
- **Rollback support**: Failed updates don't corrupt workflows
- **Validation**: Each operation validated before application

**Diff Operation Types:**
1. **Node Operations**: `add_node`, `delete_node`, `update_node_position`
2. **Property Operations**: `update_node_property`, `delete_node_property`
3. **Connection Operations**: `add_connection`, `delete_connection`
4. **Metadata Operations**: `update_workflow_metadata`

**Usage Example:**
```json
{
  "workflowId": "abc123",
  "operations": [
    {
      "type": "update_node_property",
      "nodeId": "webhook1",
      "path": "parameters.path",
      "value": "/new-webhook-path"
    },
    {
      "type": "add_node",
      "nodeId": "http1",
      "nodeData": { /* node config */ }
    }
  ]
}
```

**Important Notes:**
- Use `n8n_update_partial_workflow` instead of `n8n_update_full_workflow` when possible
- Each operation is validated before application
- Operations applied in order (dependencies matter)
- Failed operations return detailed error information
- Supports concurrent workflow modifications

### Workflow Auto-Fixer (v2.29.0+)

**Location:**
- Service: `src/services/workflow-auto-fixer.ts`
- Tool: `n8n_autofix_workflow` in `src/mcp/tools-n8n-manager.ts`

**Purpose:**
Automatically detects and fixes common workflow issues without manual intervention.

**Fixes Applied:**
1. **Missing Credentials**: Adds credential placeholders for nodes requiring authentication
2. **Invalid Connections**: Removes dangling connections to non-existent nodes
3. **Type Mismatches**: Corrects connection types (main vs. ai)
4. **Required Properties**: Adds missing required properties with defaults
5. **Breaking Changes**: Applies migrations for deprecated node versions
6. **Expression Syntax**: Fixes common expression syntax errors

**Usage:**
```typescript
// Auto-fix a workflow
n8n_autofix_workflow({
  workflowId: "abc123"
})

// Returns:
{
  "success": true,
  "fixesApplied": [
    {
      "type": "MISSING_CREDENTIAL",
      "nodeId": "googleSheets1",
      "fix": "Added credential placeholder",
      "severity": "warning"
    }
  ],
  "validationResult": { /* validation after fixes */ }
}
```

**Important Notes:**
- Always review auto-fixes before deploying to production
- Some issues may require manual intervention
- Auto-fix respects workflow structure and doesn't change logic
- Creates backup before applying fixes (if enabled)
- Returns detailed report of all fixes applied

### Recent Major Changes (v2.30.0 - v2.33.2)

**v2.33.2** (2026-01-13):
- Updated n8n to 2.3.3
- Rebuilt database with 537 core nodes

**v2.33.0** (2026-01-08):
- AI-powered documentation for 537 community nodes
- Local LLM integration (Qwen/compatible)
- README fetching from npm registry

**v2.32.0** (2026-01-07):
- Community nodes support (547 nodes total)
- Source filtering in `search_nodes`
- Verified community nodes from Strapi API
- Dynamic AI Tool node inference

**v2.31.0** (2026-01-05):
- Telemetry system for anonymous usage analytics
- Privacy-first workflow sanitization
- Performance monitoring

**v2.30.0** (2025-12-28):
- Trigger system (webhook/form/chat)
- `n8n_test_workflow` tool
- n8n native integration (MCPNode)

**Breaking Changes:**
- **v2.31.8**: `USE_FIXED_HTTP` deprecated (SSE support required)
- **v2.32.0**: Community node names are lowercase

### Database Schema Notes

The SQLite database (`data/nodes.db`) contains:
- **nodes table**: All node definitions (core + community)
- **nodes_fts5 table**: Full-text search index
- **templates table**: Workflow templates from n8n.io
- **template_nodes table**: Template node configurations
- **migrations table**: Schema version tracking

**Key Columns (nodes table):**
- Community support: `is_community`, `is_verified`, `author_name`, `npm_downloads`
- AI docs: `npm_readme`, `ai_documentation_summary`, `ai_summary_generated_at`
- Versioning: `version`, `type_version`, `default_version`
- Classification: `is_ai_tool`, `ai_tool_mode`, `ai_tool_confidence`

**Indexes:**
- FTS5 on `node_type`, `display_name`, `description`, `documentation`
- B-tree on `is_community`, `is_verified`, `is_ai_tool`
- Composite index on `node_type + version`

## Testing Infrastructure

### Test Organization
- **Unit Tests**: `tests/unit/` - 3,000+ tests covering all services and utilities
- **Integration Tests**: `tests/integration/` - n8n API integration, database operations
- **E2E Tests**: `tests/e2e/` - End-to-end workflow scenarios
- **Benchmarks**: `tests/benchmarks/` - Performance benchmarking

### Test Coverage
- Current coverage: 85%+ across the codebase
- Services: 90%+ coverage
- MCP Tools: 80%+ coverage
- Critical paths: 95%+ coverage

### Key Test Files
- `tests/unit/services/workflow-validator.test.ts` - Workflow validation
- `tests/unit/services/workflow-diff-engine.test.ts` - Diff engine
- `tests/unit/services/workflow-auto-fixer.test.ts` - Auto-fixer
- `tests/unit/http-server/session-persistence.test.ts` - Session persistence
- `tests/integration/n8n-api/*.test.ts` - n8n API integration

### Testing Best Practices
1. Always run `npm run build` before testing
2. Use `npm run test:coverage` to check coverage
3. Integration tests require n8n API credentials
4. Mock external services in unit tests
5. Use factories (fishery) for test data generation

## Environment Variables Reference

### Core Configuration
```bash
# Server Mode
MCP_MODE=stdio|http              # Server mode (default: stdio)
N8N_MODE=true                    # Enable n8n integration mode

# Database
DATABASE_PATH=./data/nodes.db    # SQLite database path

# Logging
LOG_LEVEL=error|warn|info|debug  # Log level (default: error)
DISABLE_CONSOLE_OUTPUT=true      # Disable console output (stdio mode)
```

### n8n API Integration
```bash
N8N_API_URL=https://your.n8n.instance  # n8n instance URL
N8N_API_KEY=your-api-key               # n8n API key
```

### Community Nodes & AI Documentation
```bash
N8N_MCP_LLM_BASE_URL=http://localhost:1234/v1  # LLM API endpoint
N8N_MCP_LLM_MODEL=qwen3-4b-thinking-2507       # LLM model name
N8N_MCP_LLM_TIMEOUT=60000                       # Request timeout (ms)
```

### Telemetry
```bash
N8N_MCP_TELEMETRY_DISABLED=true     # Disable telemetry
N8N_MCP_TELEMETRY_DEBUG=true        # Enable debug logs
N8N_MCP_TELEMETRY_ENDPOINT=<url>    # Custom endpoint
```

### HTTP Server
```bash
N8N_MCP_PORT=3000                    # HTTP server port
N8N_MCP_AUTH_TOKEN=your-token        # API authentication token
N8N_MCP_MAX_SESSIONS=100             # Max concurrent sessions
```

## Codebase Statistics

- **Total Files**: ~150 TypeScript files
- **Lines of Code**: ~45,000 (excluding tests)
- **Test Files**: ~100 test files
- **Test Coverage**: 85%+
- **Dependencies**: 20 production, 15 dev dependencies
- **MCP Tools**: 18 tools
- **Database Tables**: 4 main tables + FTS5 indexes
- **Node Count**: 1,084 nodes (537 core + 547 community)
- **Template Count**: 2,709 workflow templates
- **Supported Node Types**: 265 AI tool variants detected

## Key Files to Know

### Entry Points
- `src/mcp/index.ts` - Main MCP server entry point
- `src/index.ts` - Library exports
- `src/http-server-single-session.ts` - HTTP server implementation

### Core Services
- `src/services/workflow-validator.ts` - Workflow validation engine
- `src/services/workflow-diff-engine.ts` - Diff-based updates
- `src/services/workflow-auto-fixer.ts` - Auto-repair system
- `src/services/node-migration-service.ts` - Version migrations
- `src/database/node-repository.ts` - Database access layer

### MCP Implementation
- `src/mcp/server.ts` - MCP protocol implementation
- `src/mcp/tools.ts` - Documentation tools
- `src/mcp/tools-n8n-manager.ts` - Workflow management tools
- `src/mcp/tools-documentation.ts` - Tool documentation system

### Community & AI
- `src/community/community-node-service.ts` - Community node management
- `src/community/documentation-generator.ts` - AI doc generation
- `src/triggers/trigger-detector.ts` - Workflow trigger detection

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
- When you make changes to MCP server, you need to ask the user to reload it before you test
- When the user asks to review issues, you should use GH CLI to get the issue and all the comments
- When the task can be divided into separated subtasks, you should spawn separate sub-agents to handle them in paralel
- Use the best sub-agent for the task as per their descriptions
- Do not use hyperbolic or dramatic language in comments and documentation
- Add to every commit and PR: Concieved by Romuald Członkowski - and then link to www.aiadvisors.pl/en. Don't add it in conversations