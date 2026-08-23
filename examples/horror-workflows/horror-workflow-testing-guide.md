# Horror YouTube Workflow - Complete Setup & Testing Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Credential Setup](#credential-setup)
4. [Environment Configuration](#environment-configuration)
5. [Workflow Installation](#workflow-installation)
6. [Testing Procedures](#testing-procedures)
7. [Deployment Checklist](#deployment-checklist)
8. [Monitoring & Maintenance](#monitoring--maintenance)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

---

## Quick Start

**Time to Production**: ~2-3 hours

```bash
# 1. Import workflow (5 minutes)
# 2. Configure credentials (1-2 hours)
# 3. Set environment variables (10 minutes)
# 4. Test workflow (30 minutes)
# 5. Deploy and monitor (ongoing)
```

---

## Prerequisites

### Required Software

- **n8n Instance** (Self-hosted or n8n Cloud)
  - Minimum version: 1.0.0
  - Recommended: Latest stable version
  - Memory: 2GB RAM minimum
  - Storage: 10GB available space

### Required Accounts

1. **Google Account** (for YouTube)
2. **OpenAI Account** (for AI content generation)
3. **Twitter Developer Account** (for posting tweets)
4. **Discord Account** (for bot setup)
5. **Airtable Account** (for content cataloging)
6. **Slack Workspace** (for error notifications)

### Required APIs & Services

- YouTube Data API v3
- OpenAI API
- Twitter API v2
- Discord Bot API
- Airtable API
- Slack Webhook

---

## Credential Setup

### 1. OpenAI API

**Purpose**: AI-powered content enhancement (titles, descriptions, tags)

**Setup Steps**:

1. Go to https://platform.openai.com/api-keys
2. Sign up or log in
3. Navigate to API Keys section
4. Click "Create new secret key"
5. Copy the key (you won't see it again!)
6. Name it: `n8n-horror-workflow`

**n8n Configuration**:
```
Credential Name: openai-credentials
API Key: [your-openai-api-key]
Organization: [optional, if you have one]
```

**Cost Estimate**: ~$0.01-0.05 per day
- GPT-4: ~$0.01-0.03 per request
- Expected daily usage: 1-3 requests
- Monthly cost: ~$0.30-1.50

**Quota Limits**:
- Free tier: $18 credit for new accounts
- Pay-as-you-go: $5 minimum
- Rate limit: 200 requests/minute

---

### 2. Google YouTube API

**Purpose**: Upload videos to YouTube channel

**Setup Steps**:

1. Go to https://console.cloud.google.com/
2. Create a new project:
   - Click "Select a project" → "New Project"
   - Name: `n8n-horror-workflow`
   - Click "Create"

3. Enable YouTube Data API v3:
   - Navigate to "APIs & Services" → "Library"
   - Search for "YouTube Data API v3"
   - Click "Enable"

4. Configure OAuth 2.0 consent screen:
   - Go to "APIs & Services" → "OAuth consent screen"
   - Choose "External" → "Create"
   - Fill in required fields:
     - App name: `n8n Horror Workflow`
     - User support email: [your email]
     - Developer contact: [your email]
   - Add scopes:
     - `https://www.googleapis.com/auth/youtube`
     - `https://www.googleapis.com/auth/youtube.upload`
   - Add test users (your email)
   - Click "Save and Continue"

5. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: "Web application"
   - Name: `n8n-horror-workflow`
   - Authorized redirect URIs: Add your n8n instance URL
     - Example: `https://your-n8n-instance.com/rest/oauth2-credential/callback`
   - Click "Create"
   - Copy Client ID and Client Secret

**n8n Configuration**:
```
Credential Name: google-youtube-credentials
Authentication Type: OAuth2
Client ID: [your-client-id]
Client Secret: [your-client-secret]
Scope: https://www.googleapis.com/auth/youtube.upload
```

**Quota Limits**:
- Daily uploads: 100 videos/day
- Video size: 256GB or 12 hours
- Rate limit: 2,000 units/second

---

### 3. Twitter API

**Purpose**: Post horror content promotions to Twitter

**Setup Steps**:

1. Go to https://developer.twitter.com/
2. Sign up for developer account
3. Create a new app:
   - Navigate to "Projects & Apps" → "Create App"
   - App name: `n8n-horror-workflow`
   - Description: `Automated horror content posting`
   - Website: [your website or n8n instance URL]

4. Configure app permissions:
   - Go to app settings
   - Enable "Read and Write" permissions
   - Enable "OAuth 1.0a"
   - Enable "OAuth 2.0"

5. Generate keys and tokens:
   - Go to "Keys and tokens" tab
   - Generate API Key and API Secret
   - Generate Access Token and Access Token Secret
   - Copy all four values

**n8n Configuration**:
```
Credential Name: twitter-credentials
API Key: [your-api-key]
API Secret: [your-api-secret]
Access Token: [your-access-token]
Access Token Secret: [your-access-token-secret]
```

**Quota Limits**:
- Free tier: 1,500 tweets/month (50/day)
- Paid tier: 10,000 tweets/month
- Rate limit: 300 requests/15 minutes

---

### 4. Discord Bot

**Purpose**: Notify Discord community about new content

**Setup Steps**:

1. Go to https://discord.com/developers/applications
2. Create a new application:
   - Click "New Application"
   - Name: `n8n Horror Workflow Bot`
   - Click "Create"

3. Create a bot user:
   - Navigate to "Bot" section
   - Click "Add Bot"
   - Confirm by clicking "Yes, do it!"

4. Configure bot permissions:
   - Under "Privileged Gateway Intents", enable:
     - Message Content Intent
     - Server Members Intent
   - Under "Bot Permissions", select:
     - Send Messages
     - Embed Links
     - Attach Files

5. Generate bot token:
   - Click "Reset Token" (or "Copy Token" if already exists)
   - Copy the token (you won't see it again!)

6. Get channel ID:
   - Enable Developer Mode in Discord (Settings → Advanced)
   - Right-click your horror channel → "Copy Link"
   - Extract channel ID from URL (last part)
   - Example: `https://discord.com/chances/[server-id]/[channel-id]`

**n8n Configuration**:
```
Credential Name: discord-credentials
Bot Token: [your-bot-token]
```

**Environment Variable**:
```bash
DISCORD_HORROR_CHANNEL_ID=your_channel_id_here
```

**Quota Limits**:
- Free tier: Unlimited
- Rate limit: 50 messages/5 seconds per channel

---

### 5. Airtable API

**Purpose**: Catalog horror content for tracking and analytics

**Setup Steps**:

1. Go to https://airtable.com/
2. Sign up or log in
3. Create a new base:
   - Click "Create a base"
   - Name: `Horror Content Catalog`
   - Choose "Start from scratch"

4. Create a table:
   - Table name: `HorrorContent`
   - Add columns:
     - `Title` (Single line text)
     - `VideoID` (Single line text)
     - `UploadDate` (Date)
     - `Tags` (Single line text or multiple select)
     - `EngagementScore` (Number)
     - `IdempotencyKey` (Single line text)

5. Generate API key:
   - Go to https://airtable.com/create/tokens
   - Click "Create new token"
   - Name: `n8n-horror-workflow`
   - Scopes: Select your base
   - Access permissions: Read and write
   - Click "Create token"
   - Copy the token

6. Get base ID:
   - Open your base in Airtable
   - Base ID is the first part of the URL
   - Example: `https://airtable.com/[base-id]/[table-name]`

**n8n Configuration**:
```
Credential Name: airtable-credentials
API Key: [your-api-token]
```

**Environment Variable**:
```bash
AIRTABLE_BASE_ID=your_base_id_here
```

**Quota Limits**:
- Free tier: 1,000 records/base
- Rate limit: 5 requests/second

---

### 6. Slack Webhook

**Purpose**: Receive error notifications

**Setup Steps**:

1. Go to https://api.slack.com/apps
2. Create a new app:
   - Click "Create New App"
   - Choose "From scratch"
   - App name: `n8n Horror Workflow`
   - Workspace: [your workspace]
   - Click "Create App"

3. Enable incoming webhooks:
   - Navigate to "Incoming Webhooks"
   - Toggle "Activate Incoming Webhooks" to ON
   - Click "Add New Webhook to Workspace"
   - Select channel: `#horror-workflow-alerts`
   - Click "Allow"
   - Copy the webhook URL

**n8n Configuration**:
```
Credential Name: slack-credentials
Webhook URL: [your-webhook-url]
```

**Environment Variable** (optional):
```bash
WEBHOOK_ERROR_LOGGING_URL=https://your-logging-service.com/webhook
```

**Quota Limits**:
- Free tier: Unlimited webhooks
- Rate limit: 1 message/second

---

## Environment Configuration

### Set Environment Variables

**For Self-Hosted n8n**:

Add to your `.env` file or environment:

```bash
# Discord Configuration
DISCORD_HORROR_CHANNEL_ID=123456789012345678

# Airtable Configuration
AIRTABLE_BASE_ID=appXXXXXXXXXXXXXX

# Optional: Error Logging Webhook
WEBHOOK_ERROR_LOGGING_URL=https://your-logging-service.com/webhook
```

**For n8n Cloud**:

1. Go to Settings → Variables
2. Add each variable:
   - Name: `DISCORD_HORROR_CHANNEL_ID`
   - Value: `your_channel_id`
   - Repeat for other variables

**For Docker**:

Add to your `docker-compose.yml`:

```yaml
services:
  n8n:
    image: n8nio/n8n
    environment:
      - DISCORD_HORROR_CHANNEL_ID=123456789012345678
      - AIRTABLE_BASE_ID=appXXXXXXXXXXXXXX
      - WEBHOOK_ERROR_LOGGING_URL=https://your-logging-service.com/webhook
```

---

## Workflow Installation

### Import Workflow

**Option 1: Via n8n UI**

1. Log in to your n8n instance
2. Click "Workflows" in the left sidebar
3. Click "Import from File" (top right)
4. Select `horror-youtube-daily-workflow-v2-improved.json`
5. Click "Import"
6. Review the workflow structure
7. Click "Save Workflow"

**Option 2: Via API**

```bash
curl -X POST "https://your-n8n-instance.com/rest/workflows/import" \
  -H "Content-Type: application/json" \
  -d @horror-youtube-daily-workflow-v2-improved.json \
  -H "Authorization: Bearer YOUR_N8N_API_KEY"
```

**Option 3: Via Database** (advanced)

1. Connect to your n8n database
2. Insert workflow JSON into `workflow_entity` table
3. Restart n8n

---

## Testing Procedures

### Phase 1: Credential Validation (15 minutes)

**Test each credential individually**:

1. **OpenAI API Test**:
   ```javascript
   // Create a test workflow with OpenAI node
   // Prompt: "Generate a horror movie title"
   // Expected: Valid JSON response
   ```

2. **YouTube API Test**:
   ```javascript
   // Create a test workflow with YouTube node
   // Operation: "Get Videos"
   // Expected: List of videos from your channel
   ```

3. **Twitter API Test**:
   ```javascript
   // Create a test workflow with Twitter node
   // Operation: "Search Tweets" for "#horror"
   // Expected: List of horror tweets
   ```

4. **Discord Bot Test**:
   ```javascript
   // Create a test workflow with Discord node
   // Operation: "Send Message" to test channel
   // Expected: Message appears in Discord
   ```

5. **Airtable API Test**:
   ```javascript
   // Create a test workflow with Airtable node
   // Operation: "List Records"
   // Expected: Records from HorrorContent table
   ```

6. **Slack Webhook Test**:
   ```javascript
   // Create a test workflow with Slack node
   // Operation: "Post Message" to alerts channel
   // Expected: Message appears in Slack
   ```

**Validation Checklist**:
- [ ] All credentials return valid responses
- [ ] No authentication errors
- [ ] Rate limits are acceptable
- [ ] Permissions are correct

---

### Phase 2: Component Testing (30 minutes)

**Test each workflow component**:

1. **Schedule Trigger Test**:
   - Change interval to 1 minute for testing
   - Run workflow manually
   - Expected: Workflow executes every minute

2. **RSS Feed Test**:
   - Test with real Bloody Disgusting feed
   - Expected: Array of horror news items

3. **Content Processing Test**:
   - Verify idempotency key generation
   - Verify engagement scoring
   - Expected: Processed horror content with metadata

4. **Quality Filter Test**:
   - Test with low engagement content (< 60)
   - Test with high engagement content (> 60)
   - Expected: Only high engagement content passes

5. **Deduplication Test**:
   - Run workflow twice with same content
   - Expected: Second run skips duplicate content

6. **AI Enhancement Test**:
   - Test with real horror content
   - Expected: Valid JSON with title, description, tags

7. **YouTube Upload Test**:
   - Test with small video file (< 10MB)
   - Expected: Video uploaded successfully

8. **Twitter Post Test**:
   - Test with sample tweet
   - Expected: Tweet posted successfully

9. **Discord Notification Test**:
   - Test with sample message
   - Expected: Message appears in Discord channel

10. **Airtable Catalog Test**:
    - Test with sample data
    - Expected: Record created in Airtable

---

### Phase 3: Integration Testing (45 minutes)

**Test complete workflow**:

1. **End-to-End Test**:
   - Use manual trigger instead of schedule
   - Use test RSS feed with limited items
   - Monitor each node execution
   - Expected: Complete workflow execution

2. **Error Handling Test**:
   - Simulate failure in each node
   - Test error trigger and notifications
   - Expected: Errors caught and reported to Slack

3. **Idempotency Test**:
   - Run workflow 3 times with same data
   - Check for duplicate posts
   - Expected: No duplicate content posted

4. **Performance Test**:
   - Time workflow execution
   - Check memory usage
   - Expected: < 60 seconds total execution time

5. **Load Test** (optional):
   - Process 10+ items in single run
   - Expected: All items processed successfully

---

### Phase 4: Production Readiness Test (30 minutes)

**Pre-deployment validation**:

1. **Security Review**:
   - [ ] No hardcoded credentials
   - [ ] All secrets in credential manager
   - [ ] Environment variables configured
   - [ ] API permissions are minimal required

2. **Performance Review**:
   - [ ] Timeouts configured on all API nodes
   - [ ] Retry logic implemented
   - [ ] Rate limits within bounds
   - [ ] Idempotency keys working

3. **Error Handling Review**:
   - [ ] Error trigger node active
   - [ ] Error notifications working
   - [ ] Fallback values set
   - [ ] Logging enabled

4. **Content Quality Review**:
   - [ ] AI prompts tested
   - [ ] Quality filtering working
   - [ ] Content validation in place
   - [ ] Age-appropriate ratings set

5. **Monitoring Setup**:
   - [ ] Execution logs enabled
   - [ ] Error tracking active
   - [ ] Analytics tracking configured
   - [ ] Alerts configured

---

## Deployment Checklist

### Pre-Deployment (1 hour before)

- [ ] All credentials configured and tested
- [ ] Environment variables set
- [ ] Workflow imported and saved
- [ ] Test runs completed successfully
- [ ] Error handling tested
- [ ] Team notified of deployment
- [ ] Rollback plan prepared

### Deployment (5 minutes)

- [ ] Change schedule from test to production (24 hours)
- [ ] Activate workflow (toggle ON)
- [ ] Verify workflow appears in active list
- [ ] Check first scheduled execution
- [ ] Monitor initial execution logs

### Post-Deployment (30 minutes after)

- [ ] Verify first YouTube upload
- [ ] Verify Twitter post
- [ ] Verify Discord notification
- [ ] Verify Airtable record
- [ ] Check for any errors
- [ ] Monitor for 1 hour

### Day 1 Monitoring

- [ ] Check all scheduled executions
- [ ] Verify content quality
- [ ] Monitor engagement metrics
- [ ] Check error logs
- [ ] Verify no duplicate posts

---

## Monitoring & Maintenance

### Daily Tasks (5 minutes)

- Check execution logs for errors
- Verify posts appeared on YouTube/Twitter
- Monitor engagement metrics
- Check API quota usage

### Weekly Tasks (30 minutes)

- Review performance analytics
- Check API costs
- Test error handling
- Review content quality
- Update RSS feed sources if needed

### Monthly Tasks (1 hour)

- Rotate API credentials
- Review and optimize prompts
- Update dependencies
- Performance audit
- Cost analysis

### Quarterly Tasks (2 hours)

- Feature enhancement review
- Security audit
- Workflow optimization
- Documentation update
- Team training

---

## Troubleshooting

### Common Issues

#### Issue: Workflow Not Executing

**Symptoms**: Schedule trigger not firing

**Solutions**:
1. Check workflow is activated (toggle ON)
2. Verify schedule settings
3. Check n8n instance is running
4. Review browser console for errors
5. Check n8n logs: `docker logs n8n`

---

#### Issue: YouTube Upload Fails

**Symptoms**: Error uploading video

**Solutions**:
1. Verify OAuth token is valid
2. Check video file size (< 256GB)
3. Verify video format (MP4 recommended)
4. Check YouTube API quota
5. Re-authenticate OAuth credentials

---

#### Issue: OpenAI API Timeout

**Symptoms**: AI enhancement node times out

**Solutions**:
1. Increase timeout from 30s to 60s
2. Check OpenAI API status
3. Reduce prompt complexity
4. Verify API key is valid
5. Check OpenAI account balance

---

#### Issue: Duplicate Posts

**Symptoms**: Same content posted multiple times

**Solutions**:
1. Verify idempotency keys are working
2. Check deduplication logic
3. Review static data configuration
4. Test with same content twice
5. Enable content database deduplication

---

#### Issue: Discord Bot Not Posting

**Symptoms**: No messages in Discord channel

**Solutions**:
1. Verify bot token is valid
2. Check bot has message permissions
3. Verify channel ID is correct
4. Ensure bot is added to server
5. Check Discord rate limits

---

### Debug Mode

Enable debug logging:

```javascript
// Add to any code node
console.log('DEBUG:', JSON.stringify($input.all(), null, 2));
```

View logs:
- Self-hosted: Check n8n logs
- Cloud: Use execution history
- Browser: Open DevTools Console

---

## FAQ

### Q: Can I customize the posting schedule?

**A**: Yes! Edit the Schedule Trigger node:
- Daily: Set interval to 24 hours
- Twice daily: Set interval to 12 hours
- Weekly: Set interval to 168 hours
- Custom time: Use cron expression

### Q: What if I don't have all the APIs?

**A**: The workflow can run with partial functionality:
- Without YouTube: Posts to social media only
- Without OpenAI: Uses original content without AI enhancement
- Without Twitter/Discord: Posts to YouTube only
- Without Airtable: No content cataloging

### Q: How much does this cost per month?

**A**: Estimated costs:
- n8n Cloud: ~$20/month (or self-host free)
- OpenAI: ~$0.30-1.50/month
- Total: ~$20-22/month (or $0.30-1.50 if self-hosted)

### Q: Can I use multiple RSS feeds?

**A**: Yes! Duplicate the RSS Feed node or merge multiple feeds using a Merge node.

### Q: How do I add content moderation?

**A**: Add an If node after AI Content Enhancer to filter:
- Inappropriate keywords
- Content length limits
- Age rating requirements

### Q: Can I customize the AI prompts?

**A**: Yes! Edit the AI Content Enhancer node:
- Change the system message
- Modify the user prompt
- Adjust temperature (0-2, higher = more creative)
- Adjust maxTokens (response length)

### Q: What if YouTube upload fails?

**A**: The workflow includes:
- Retry logic (2 attempts with 5s delay)
- Error notifications to Slack
- Failed content logged for manual review
- No data loss (content preserved in static data)

### Q: Can I post to other platforms?

**A**: Yes! n8n supports many platforms:
- Facebook
- Instagram
- LinkedIn
- TikTok
- Reddit
- And many more!

---

## Support

**Documentation**: https://docs.n8n.io
**Community**: https://community.n8n.io
**GitHub**: https://github.com/n8n-io/n8n

**Conceived by Romuald Członkowski - https://www.aiadvisors.pl/en**

---

*Last Updated: 2025-01-22*
*Version: 2.0 (Improved)*
