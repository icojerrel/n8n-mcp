# n8n-mcp Test Workflow Specification

## Purpose
Validate all key features documented in CLAUDE.md through a comprehensive test workflow.

## Test Workflow: "n8n-mcp Feature Validation Suite"

### Objective
Demonstrate and validate the complete n8n-mcp toolchain:
1. Node discovery (search_nodes)
2. Node configuration (get_node)
3. Node validation (validate_node)
4. Workflow creation (n8n_create_workflow)
5. Workflow validation (validate_workflow)
6. Partial updates (n8n_update_partial_workflow)
7. Auto-fix capabilities (n8n_autofix_workflow)
8. Template deployment (n8n_deploy_template)

### Test Scenarios

#### Scenario 1: Discover and Configure HTTP Request Node
**Steps:**
1. Search for "HTTP Request" nodes using `search_nodes`
2. Get detailed configuration for `@n8n/n8n-nodes-base.httpRequest` using `get_node`
3. Extract required properties and create valid configuration
4. Validate single node configuration using `validate_node`

**Expected Result:**
- Find HTTP Request node successfully
- Retrieve complete node schema
- Create valid configuration
- Pass validation with profile='ai-friendly'

#### Scenario 2: Build Simple Webhook → HTTP → Set Workflow
**Steps:**
1. Create workflow with 3 nodes:
   - Webhook trigger (GET /test)
   - HTTP Request (to httpbin.org/get)
   - Set node (format response)
2. Validate workflow structure using `validate_workflow`
3. Test connections and property dependencies

**Expected Result:**
- Workflow structure is valid
- All connections are correct
- No validation errors
- Ready for deployment

#### Scenario 3: Test Partial Update System
**Steps:**
1. Create base workflow
2. Update webhook path using `n8n_update_partial_workflow`
3. Add new HTTP header using partial update
4. Verify changes applied correctly
5. Measure token savings vs full update

**Expected Result:**
- Partial updates succeed
- 80-90% token savings achieved
- Workflow remains valid after updates
- No data corruption

#### Scenario 4: Auto-Fix Validation Errors
**Steps:**
1. Create workflow with intentional errors:
   - Missing required property
   - Invalid connection type
   - Incorrect credential placeholder
2. Run `validate_workflow` to identify errors
3. Apply `n8n_autofix_workflow`
4. Validate fixed workflow

**Expected Result:**
- Errors detected correctly
- Auto-fix applies corrections
- Workflow becomes valid
- Fix report shows all changes

#### Scenario 5: Template Deployment
**Steps:**
1. Search templates for "webhook" using `search_templates`
2. Select suitable template
3. Get template details using `get_template`
4. Deploy template using `n8n_deploy_template`
5. Validate deployed workflow

**Expected Result:**
- Template found successfully
- Template metadata retrieved
- Deployment succeeds
- Deployed workflow is valid

#### Scenario 6: Community Nodes Discovery
**Steps:**
1. Search community nodes using `search_nodes` with source='community'
2. Filter for verified nodes using source='verified'
3. Get node details for a community node
4. Verify AI documentation is available

**Expected Result:**
- Community nodes found
- Verified filtering works
- Node details include community metadata
- AI documentation summary present

### Success Criteria

**Must Pass:**
- ✅ All 6 scenarios complete without errors
- ✅ Validation succeeds with appropriate profiles
- ✅ Partial updates show 80%+ token savings
- ✅ Auto-fix resolves common validation errors
- ✅ Template deployment creates valid workflow
- ✅ Community nodes are discoverable

**Performance Targets:**
- search_nodes: < 1s response time
- get_node: < 500ms for minimal detail
- validate_node: < 200ms per node
- validate_workflow: < 2s for 10-node workflow
- n8n_update_partial_workflow: < 1s

**Quality Metrics:**
- Validation accuracy: 95%+ correct error detection
- Auto-fix success rate: 80%+ issues resolved
- Documentation completeness: 90%+ properties documented
- Token efficiency: 85%+ savings on partial updates

## Test Workflow Implementation

Below is the complete n8n workflow JSON for testing.
