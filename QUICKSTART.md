# n8n-mcp Quick Start Guide

Get started building n8n workflows with Claude in 5 minutes.

**Prerequisites**: n8n-mcp installed (see `INSTALL.md`)

---

## 5-Minute Quick Start

### 1. Start the MCP Server

```bash
# Option A: stdio mode (for Claude Desktop)
npm start

# Option B: HTTP mode (for testing)
npm run start:http
```

### 2. Open Claude Desktop

Make sure Claude Desktop is configured with n8n-mcp (see `INSTALL.md` Step 2).

### 3. Ask Claude to Build a Workflow

Try these example prompts:

**Example 1: Simple Webhook to HTTP**
```
Create an n8n workflow that:
- Triggers on webhook GET /hello
- Makes HTTP request to httpbin.org/get
- Returns the response as JSON
```

**Example 2: Database Workflow**
```
Build a workflow that:
- Triggers on webhook POST /user
- Extracts name and email from body
- Inserts into PostgreSQL database
- Returns success message
```

**Example 3: AI Workflow**
```
Create a workflow that:
- Triggers on webhook POST /chat
- Sends message to OpenAI ChatGPT
- Returns AI response
```

---

## Understanding the Workflow Building Process

### Phase 1: Discovery

Claude will use `search_nodes` to find the right nodes:

```
You: "I need to make an HTTP request"

Claude uses: search_nodes({ query: "HTTP", source: "core" })

Result: Finds @n8n/n8n-nodes-base.httpRequest
```

### Phase 2: Configuration

Claude will use `get_node` to understand how to configure nodes:

```
Claude uses: get_node({
  nodeType: "@n8n/n8n-nodes-base.httpRequest",
  detail: "standard"
})

Result: Gets required properties (url, method, etc.)
```

### Phase 3: Validation

Claude will use `validate_workflow` to ensure correctness:

```
Claude uses: validate_workflow(workflow, {
  profile: "ai-friendly"
})

Result: Checks structure, connections, required properties
```

### Phase 4: Deployment (Optional)

If you configured n8n API, Claude can deploy directly:

```
Claude uses: n8n_create_workflow(workflow)

Result: Workflow created in your n8n instance
```

---

## Common Workflow Patterns

### Pattern 1: Webhook → HTTP → Response

**Use Case**: API proxy, data fetching

```
Ask Claude:
"Create a webhook that fetches data from an API and returns it"
```

**What you'll get**:
1. Webhook Trigger (GET /endpoint)
2. HTTP Request node (to external API)
3. Respond to Webhook node (return JSON)

### Pattern 2: Webhook → Database → Response

**Use Case**: CRUD operations, data storage

```
Ask Claude:
"Create a workflow to insert user data into PostgreSQL"
```

**What you'll get**:
1. Webhook Trigger (POST /users)
2. PostgreSQL node (INSERT operation)
3. Respond to Webhook node (return success)

### Pattern 3: Schedule → HTTP → Process → Database

**Use Case**: Data synchronization, ETL

```
Ask Claude:
"Create a scheduled workflow that fetches data every hour and saves to database"
```

**What you'll get**:
1. Schedule Trigger (cron: 0 * * * *)
2. HTTP Request node (fetch data)
3. Code node (transform data)
4. Database node (save data)

### Pattern 4: Webhook → AI → Response

**Use Case**: Chatbots, AI assistants

```
Ask Claude:
"Create a chatbot using OpenAI that responds to user messages"
```

**What you'll get**:
1. Webhook Trigger (POST /chat)
2. OpenAI ChatGPT node
3. Respond to Webhook node (return AI response)

### Pattern 5: Email → Process → Notify

**Use Case**: Email automation, notifications

```
Ask Claude:
"Create a workflow that processes incoming emails and sends Slack notifications"
```

**What you'll get**:
1. Email Trigger (IMAP)
2. Code node (extract data)
3. Slack node (send message)

---

## Tips for Better Workflows

### Tip 1: Be Specific About Requirements

**Bad**:
```
"Create a workflow"
```

**Good**:
```
"Create a workflow that:
- Triggers on webhook POST /contact
- Validates email format
- Sends to Mailchimp
- Returns confirmation"
```

### Tip 2: Specify Error Handling

```
"Create a workflow with error handling that:
- Retries failed HTTP requests 3 times
- Sends error notification to Slack
- Returns user-friendly error message"
```

### Tip 3: Include Data Transformation

```
"Create a workflow that:
- Fetches user data from API
- Transforms date format to ISO 8601
- Maps fields: firstName → first_name
- Saves to database"
```

### Tip 4: Request Validation

```
"Create a workflow with validation that checks:
- Email is valid format
- Name is at least 2 characters
- Age is between 18-120
Return validation errors if checks fail"
```

### Tip 5: Use Community Nodes (When Needed)

```
"Create a workflow using ChatGPT community node for AI responses"

Claude will search verified community nodes and use the best match.
```

---

## Testing Your Workflows

### Test with validate_workflow

Ask Claude to validate before deploying:

```
"Validate this workflow before deploying"
```

Claude will use `validate_workflow` with profile='ai-friendly' to check for:
- Missing required properties
- Invalid connections
- Type mismatches
- Breaking changes

### Test with n8n_test_workflow

If workflow has a trigger (webhook/form/chat):

```
"Test this workflow with a sample webhook call"
```

Claude will use `n8n_test_workflow` to execute the workflow.

### Test Manually

```bash
# For webhook workflows
curl -X POST http://your-n8n-instance.com/webhook/your-path \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

---

## Using n8n-mcp Tools Directly

### Search for Nodes

```
"Search for nodes related to database operations"
```

Uses: `search_nodes({ query: "database", source: "all" })`

### Get Node Details

```
"Show me how to configure the PostgreSQL node"
```

Uses: `get_node({ nodeType: "@n8n/n8n-nodes-base.postgres", detail: "standard" })`

### List Templates

```
"Show me workflow templates for webhooks"
```

Uses: `search_templates({ query: "webhook" })`

### Deploy Template

```
"Deploy the 'Simple webhook to HTTP' template"
```

Uses: `n8n_deploy_template({ templateId: "123" })`

### Auto-Fix Workflow

```
"My workflow has validation errors, can you auto-fix them?"
```

Uses: `n8n_autofix_workflow({ workflowId: "abc123" })`

---

## Common Issues & Solutions

### Issue: "Node not found"

**Solution**: Be more specific with node type

```
Bad:  "Use the HTTP node"
Good: "Use the HTTP Request node (@n8n/n8n-nodes-base.httpRequest)"
```

### Issue: "Validation failed - missing credentials"

**Solution**: Ask for placeholder credentials

```
"Create workflow with credential placeholders"
```

Claude will use `ignoreCredentials: true` in validation.

### Issue: "Workflow too complex"

**Solution**: Break into smaller workflows

```
"Create 3 separate workflows:
1. Webhook → Database (user creation)
2. Schedule → API (data sync)
3. Trigger → Notification (alerts)"
```

### Issue: "Can't deploy to n8n"

**Solution**: Check n8n API configuration

```bash
# Verify .env has correct credentials
cat .env | grep N8N_API

# Test API connection
curl -H "X-N8N-API-KEY: $N8N_API_KEY" \
  $N8N_API_URL/api/v1/workflows
```

---

## Advanced Usage

### Using Multiple Validation Profiles

```
"Validate this workflow with strict profile"
```

Claude will use `profile='strict'` instead of default 'ai-friendly'.

### Partial Workflow Updates

```
"Update only the webhook path in my workflow to /new-path"
```

Claude will use `n8n_update_partial_workflow` (80-90% token savings).

### Community Nodes

```
"Search for verified community nodes for ChatGPT"
```

Claude will use `source='verified'` filter.

### AI Documentation

```
"Show me AI documentation summary for the Chatwoot node"
```

Claude will retrieve AI-generated documentation (available for 537 nodes).

---

## Next Steps

### 1. Install n8n-skills (Recommended)

```
In Claude Code: /plugin install czlonkowski/n8n-skills
```

This adds 7 complementary skills that teach Claude HOW to use n8n-mcp tools effectively.

### 2. Read Full Documentation

- `CLAUDE.md` - Complete project documentation (1,244 lines)
- `MEMORY.md` - Key patterns and best practices
- `LESSONS_LEARNED.md` - Common issues and solutions

### 3. Try the Test Workflow

```bash
# Validate the test workflow
npx tsx scripts/validate-test-workflow-simple.ts
```

### 4. Build Real Workflows

Start with simple workflows and gradually increase complexity:

1. **Week 1**: Webhook → HTTP → Response
2. **Week 2**: Webhook → Database → Response
3. **Week 3**: Schedule → API → Process → Database
4. **Week 4**: Complex multi-node workflows with error handling

---

## Getting Help

### Documentation
- `CLAUDE.md` - Everything about n8n-mcp
- `INSTALL.md` - Installation guide
- This file - Quick start guide

### Community
- GitHub Issues: https://github.com/icojerrel/n8n-mcp/issues
- n8n Community: https://community.n8n.io
- n8n Documentation: https://docs.n8n.io

### Related Projects
- n8n-skills: https://github.com/czlonkowski/n8n-skills
- n8n-skills.com: https://www.n8n-skills.com

---

## Example Session

Here's a complete example of building a workflow:

```
You: "Help me build a contact form workflow"

Claude: "I'll help you create a contact form workflow. Let me search for the right nodes."

[Claude uses search_nodes to find Webhook, HTTP Request, and Email nodes]

Claude: "Here's your workflow:

1. Webhook Trigger
   - Method: POST
   - Path: /contact
   - Body: { name, email, message }

2. Email Node
   - To: support@yourcompany.com
   - Subject: New Contact Form Submission
   - Body: Template with {{$json.name}}, {{$json.email}}, {{$json.message}}

3. Respond to Webhook
   - Status: 200
   - Body: { success: true, message: 'Thank you for contacting us!' }

Would you like me to validate this workflow?"

You: "Yes, validate it"

Claude: [Uses validate_workflow]
"✓ Workflow is valid
 - 0 errors
 - 0 warnings
 - Ready to deploy"

You: "Deploy it to my n8n instance"

Claude: [Uses n8n_create_workflow]
"✓ Workflow deployed successfully
 - ID: 42
 - URL: https://your-instance.com/workflow/42
 - Webhook URL: https://your-instance.com/webhook/contact

Your contact form is ready to use!"
```

---

**Ready to build workflows? Ask Claude to get started!**

**Conceived by Romuald Członkowski** - https://www.aiadvisors.pl/en
