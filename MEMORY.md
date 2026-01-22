# n8n-mcp Project Memory

This document maintains persistent memory of key decisions, patterns, and insights for AI assistants working on n8n-mcp.

**Last Updated**: 2026-01-22
**Current Version**: 2.33.2 (n8n 2.3.3)

---

## Project Identity

**What is n8n-mcp?**
A Model Context Protocol (MCP) server that provides AI assistants with comprehensive access to n8n workflow automation knowledge.

**Core Mission:**
Enable AI assistants to generate production-ready, fault-tolerant n8n workflows through:
1. **Data Access**: 18 MCP tools for querying 1,084 nodes and 2,709 templates
2. **Usage Guidance**: Integration with n8n-skills (7 Claude Code skills)
3. **Enterprise Quality**: Validation, auto-fix, and diff-based updates

---

## Architecture Decisions

### Database Strategy
**Decision**: SQLite with FTS5 full-text search
**Rationale**:
- Embedded database (no separate server needed)
- Fast full-text search for node discovery
- Universal adapter pattern (better-sqlite3 + sql.js for browser)
- Single file deployment

**Key Files**:
- `src/database/node-repository.ts` - Data access layer
- `src/database/database-adapter.ts` - Universal adapter
- `data/nodes.db` - SQLite database (1,084 nodes)

### Validation Approach
**Decision**: Multi-profile validation system
**Profiles**:
1. **minimal**: Basic structure checks (development)
2. **runtime**: Required properties + connections (AI generation)
3. **ai-friendly**: Flexible, ignores credential placeholders (AI workflows)
4. **strict**: Full validation including credentials (production)

**Rationale**: Different use cases require different validation strictness. AI-generated workflows need flexibility.

**Key Files**:
- `src/services/workflow-validator.ts` - Main validator
- `src/services/enhanced-config-validator.ts` - Operation-aware validation

### Community Nodes Integration
**Decision**: Dual-source approach (Strapi API + npm registry)
**Sources**:
1. **Verified nodes** (301): Fetched from n8n Strapi API
2. **Popular nodes** (246): Top npm packages by downloads
3. **AI Documentation** (537): Generated using local LLM (Qwen)

**Rationale**: Verified nodes have full schemas, npm provides wider coverage, AI docs fill documentation gaps.

**Key Files**:
- `src/community/community-node-fetcher.ts`
- `src/community/documentation-generator.ts`

### Update Strategy
**Decision**: Diff-based partial updates over full replacements
**Benefits**:
- 80-90% token savings
- Atomic operations with rollback
- Conflict detection
- Faster API responses

**Key Files**:
- `src/services/workflow-diff-engine.ts`
- `src/types/workflow-diff.ts`
- Tool: `n8n_update_partial_workflow`

---

## Key Patterns & Best Practices

### 1. Tool Selection Pattern
```
Discovery → Configuration → Validation → Deployment
     ↓            ↓              ↓            ↓
search_nodes  get_node   validate_workflow  n8n_create_workflow
                              ↓
                    (optional) n8n_autofix_workflow
```

**Most Common**: `search_nodes → get_node` (18s avg between steps)
**Most Used Tool**: `n8n_update_partial_workflow` (99% success rate)

### 2. Node Discovery Pattern
```typescript
// CORRECT: Use source filter for community nodes
search_nodes({
  query: "chatgpt",
  source: "verified",  // or "community", "core", "all"
  includeExamples: true
})

// INCORRECT: Missing source filter
search_nodes({ query: "chatgpt" })
```

### 3. Validation Pattern
```typescript
// For AI-generated workflows
validate_workflow(workflow, {
  profile: "ai-friendly",  // Flexible, ignores credential placeholders
  ignoreCredentials: true
})

// For production deployment
validate_workflow(workflow, {
  profile: "strict",  // Full validation
  ignoreCredentials: false
})
```

### 4. Partial Update Pattern
```typescript
// PREFERRED: Efficient partial update
n8n_update_partial_workflow({
  workflowId: "123",
  operations: [
    {
      type: "update_node_property",
      nodeId: "webhook1",
      path: "parameters.path",
      value: "/new-path"
    }
  ]
})

// AVOID: Full replacement (expensive)
n8n_update_full_workflow({
  workflowId: "123",
  workflow: entireWorkflowObject  // Wastes 80-90% tokens
})
```

### 5. Error Handling Pattern
```typescript
// 1. Validate first
const validation = await validate_workflow(workflow);

if (!validation.valid) {
  // 2. Try auto-fix
  const fixes = await n8n_autofix_workflow(workflowId);

  if (fixes.success) {
    // 3. Re-validate after fix
    await validate_workflow(workflow);
  } else {
    // 4. Manual intervention required
    console.error("Auto-fix failed:", fixes.errors);
  }
}
```

---

## Critical Performance Optimizations

### 1. LRU Caching
**Location**: `src/utils/simple-cache.ts`
**Impact**: Reduces repeated database queries by 90%
**Usage**: Node lookups, template searches, documentation fetches

### 2. FTS5 Full-Text Search
**Location**: Database schema `nodes_fts5` table
**Impact**: Sub-second search across 1,084 nodes
**Indexed Fields**: `node_type`, `display_name`, `description`, `documentation`

### 3. Batch Processing
**Location**: `src/community/documentation-batch-processor.ts`
**Impact**: Process 100+ community nodes efficiently
**Features**: Progress tracking, retry logic, rate limiting

### 4. Diff-Based Updates
**Location**: `src/services/workflow-diff-engine.ts`
**Impact**: 80-90% token savings on workflow updates
**Operation Types**: 8 diff operations (add_node, update_property, etc.)

---

## Ecosystem Integration Points

### n8n-mcp ↔ n8n-skills
**Relationship**: Complementary
- **n8n-mcp**: Provides 18 MCP tools for DATA ACCESS
- **n8n-skills**: Provides 7 Claude Code skills for USAGE GUIDANCE

**Integration**:
- Skills activate based on query context
- Most common pattern: search_nodes → get_node (18s avg)
- Skills teach expression syntax, validation, workflow patterns

**Key Stat**: Combined usage → 99% workflow success rate

### n8n-mcp ↔ n8n API
**Authentication**: `N8N_API_URL` + `N8N_API_KEY`
**Key Tools**:
- `n8n_create_workflow`: Create workflows
- `n8n_update_partial_workflow`: Efficient updates
- `n8n_validate_workflow`: Real validation with n8n API
- `n8n_test_workflow`: Execute via triggers (webhook/form/chat)

**Important**: All workflow management tools require n8n API credentials

### n8n-mcp ↔ Claude Desktop
**Protocol**: Model Context Protocol (MCP)
**Transport**: stdio mode (default) or HTTP mode
**Config**: `claude_desktop_config.json`
**Reload Required**: After any MCP server code changes

---

## Enterprise Readiness Status

### Current Maturity: 52% (Moderate)

**Strong Areas** (70%+):
- ✅ Performance Optimization (90%)
- ✅ Testing Infrastructure (85%)
- ✅ CI/CD Integration (70%)
- ✅ Security (67%)

**Critical Gaps** (<35%):
- ❌ SLA Monitoring (12%)
- ❌ Compliance & Governance (25%)
- ❌ Disaster Recovery (33%)

**Immediate Priorities**:
1. Implement exponential backoff for API retries (HIGH, LOW effort)
2. Add circuit breaker pattern (HIGH, LOW effort)
3. Set up automated backups (CRITICAL, HIGH effort)
4. Implement encryption at rest (CRITICAL, HIGH effort)

**See**: `CLAUDE.md` → "Enterprise Workflow Generation: Gap Analysis"

---

## Common Pitfalls & Solutions

### Pitfall 1: Using Full Updates Instead of Partial
**Problem**: Wastes 80-90% of tokens, slower API responses
**Solution**: Always use `n8n_update_partial_workflow` for property changes

### Pitfall 2: Wrong Validation Profile
**Problem**: `profile='strict'` fails on AI-generated workflows with credential placeholders
**Solution**: Use `profile='ai-friendly'` for AI workflows, `profile='strict'` for production

### Pitfall 3: Community Node Case Sensitivity
**Problem**: Searching for "Chatwoot" doesn't find "chatwoot"
**Solution**: Community node names are lowercase; use lowercase in searches

### Pitfall 4: Forgetting to Reload MCP Server
**Problem**: Changes to MCP server code don't take effect
**Solution**: Always ask user to reload Claude Desktop after server changes

### Pitfall 5: Missing Credential Configuration
**Problem**: Workflows fail validation due to missing credentials
**Solution**: Use `ignoreCredentials: true` during development, add placeholders for production

### Pitfall 6: Not Testing Triggers Before Deployment
**Problem**: Workflows with triggers fail without testing
**Solution**: Use `n8n_test_workflow` to verify trigger configuration before activation

---

## Testing Strategy

### Test Pyramid
1. **Unit Tests** (3,336+ tests, 85%+ coverage)
   - Location: `tests/unit/`
   - Focus: Services, utilities, parsers
   - Run: `npm test`

2. **Integration Tests**
   - Location: `tests/integration/`
   - Focus: n8n API, database operations
   - Run: `npm run test:integration`

3. **E2E Tests**
   - Location: `tests/e2e/`
   - Focus: Complete workflow scenarios
   - Run: `npm run test:e2e`

### Test Coverage Requirements
- Services: 90%+
- MCP Tools: 80%+
- Critical paths: 95%+
- Overall: 85%+

### Performance Benchmarks
- `search_nodes`: < 1s
- `get_node` (minimal): < 500ms
- `validate_node`: < 200ms per node
- `validate_workflow`: < 2s for 10-node workflow
- `n8n_update_partial_workflow`: < 1s

---

## Key Metrics & Stats

### Coverage
- **Total Nodes**: 1,084 (537 core + 547 community)
- **Verified Community**: 301 nodes
- **Property Coverage**: 99% with detailed schemas
- **Documentation Coverage**: 87% from official docs
- **AI Documentation**: 537 nodes with summaries
- **Workflow Templates**: 2,709 with 100% metadata
- **AI Tool Variants**: 265 detected

### Performance
- **Database Size**: ~50MB (SQLite)
- **FTS5 Index**: Sub-second full-text search
- **Cache Hit Rate**: 90%+ for repeated queries
- **Validation Speed**: < 2s for complex workflows
- **Token Efficiency**: 80-90% savings on partial updates

### Quality
- **Test Coverage**: 85%+
- **Test Count**: 3,336+ unit tests
- **Auto-Fix Success**: 80%+ common issues resolved
- **Validation Accuracy**: 95%+ correct error detection
- **Workflow Success Rate**: 99% (with n8n-skills)

---

## Development Workflow Reminders

### Before Making Changes
1. Read `CLAUDE.md` for project overview
2. Check `LESSONS_LEARNED.md` for recent insights
3. Review `MEMORY.md` (this file) for patterns

### After Making Changes
1. Run `npm run build` (TypeScript compilation)
2. Run `npm test` (unit tests)
3. Run `npm run typecheck` (type safety)
4. Update `LESSONS_LEARNED.md` with new insights
5. Ask user to reload MCP server if server code changed

### Before Committing
1. Ensure all tests pass
2. Update documentation if features changed
3. Add to `LESSONS_LEARNED.md` if patterns emerged
4. Use descriptive commit messages
5. Reference related issues/PRs

### Git Workflow
- Branch naming: `claude/<description>-<sessionId>`
- Always commit and push before conversation ends
- Use conventional commits (e.g., `feat:`, `fix:`, `docs:`)
- Include attribution: "Conceived by Romuald Członkowski - https://www.aiadvisors.pl/en"

---

## Environment Variables Reference

### Core Configuration
```bash
# Server Mode
MCP_MODE=stdio|http              # Default: stdio
N8N_MODE=true                    # Enable n8n integration

# Database
DATABASE_PATH=./data/nodes.db    # SQLite path

# Logging
LOG_LEVEL=error|warn|info|debug  # Default: error
DISABLE_CONSOLE_OUTPUT=true      # For stdio mode
```

### n8n API
```bash
N8N_API_URL=https://your.n8n.instance
N8N_API_KEY=your-api-key
```

### Community & AI
```bash
N8N_MCP_LLM_BASE_URL=http://localhost:1234/v1
N8N_MCP_LLM_MODEL=qwen3-4b-thinking-2507
N8N_MCP_LLM_TIMEOUT=60000
```

### Telemetry
```bash
N8N_MCP_TELEMETRY_DISABLED=true  # Opt-out
N8N_MCP_TELEMETRY_DEBUG=true     # Debug logs
```

### HTTP Server
```bash
N8N_MCP_PORT=3000
N8N_MCP_AUTH_TOKEN=your-token
N8N_MCP_MAX_SESSIONS=100
```

---

## Future Roadmap Priorities

### Phase 1: Immediate (1-2 weeks)
1. Exponential backoff for API retries
2. Circuit breaker pattern
3. Prometheus metrics export
4. Automated database backups

### Phase 2: Short-term (1-2 months)
1. Distributed tracing (OpenTelemetry)
2. Immutable audit logging
3. SLA monitoring framework
4. Multi-region deployment support
5. Encryption at rest

### Phase 3: Long-term (3-6 months)
1. Compliance reporting (GDPR, SOC2, ISO27001)
2. Disaster recovery automation
3. Workflow approval processes
4. Advanced security scanning
5. Performance optimization for 10,000+ nodes

**Estimated Total Effort**: 1,200-1,800 engineering hours

---

## References

### Key Documents
- `CLAUDE.md` - Complete project documentation (1,244 lines)
- `LESSONS_LEARNED.md` - Evolving insights and patterns
- `README.md` - User-facing documentation
- `CHANGELOG.md` - Version history

### External Resources
- [n8n-skills](https://github.com/czlonkowski/n8n-skills) - Complementary Claude Code skills
- [n8n-skills.com](https://www.n8n-skills.com/) - Skills documentation
- [n8n.io](https://n8n.io) - Workflow automation platform
- [MCP Protocol](https://modelcontextprotocol.io) - Model Context Protocol spec

---

**Maintained by**: Claude Code (AI Assistant)
**Project Owner**: Romuald Członkowski ([AI Advisors](https://www.aiadvisors.pl/en))
**Last Review**: 2026-01-22
