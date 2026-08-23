# Horror YouTube Workflow - Quick Reference Guide

## 🚀 Quick Start (30 seconds)

```bash
# 1. Import workflow into n8n
# 2. Configure 6 credentials (see below)
# 3. Set 2 environment variables
# 4. Test manually → Activate → Done!
```

---

## 📋 File Overview

| File | Purpose | Use When |
|------|---------|----------|
| `horror-youtube-daily-workflow-v2-improved.json` | Production workflow with all fixes | Deploying to production |
| `horror-workflow-validation-report.md` | Detailed validation and analysis | Reviewing workflow structure |
| `horror-workflow-testing-guide.md` | Complete setup and testing guide | First-time setup |
| `horror-workflow-quick-reference.md` | This file | Quick lookup |

---

## 🔐 Credentials Quick Setup

### 1. OpenAI (2 minutes)
```
URL: https://platform.openai.com/api-keys
Action: Create key → Copy
n8n: Create credential "openai-credentials"
Cost: ~$0.30-1.50/month
```

### 2. YouTube (30 minutes)
```
URL: https://console.cloud.google.com/
Action: Create project → Enable YouTube API v3 → Setup OAuth2
n8n: Create credential "google-youtube-credentials"
Cost: Free
```

### 3. Twitter (10 minutes)
```
URL: https://developer.twitter.com/
Action: Create app → Generate keys
n8n: Create credential "twitter-credentials"
Cost: Free tier (50 tweets/day)
```

### 4. Discord (5 minutes)
```
URL: https://discord.com/developers/applications
Action: Create bot → Copy token → Get channel ID
n8n: Create credential "discord-credentials"
Cost: Free
```

### 5. Airtable (5 minutes)
```
URL: https://airtable.com/
Action: Create base → Get API token → Get base ID
n8n: Create credential "airtable-credentials"
Cost: Free tier (1,000 records)
```

### 6. Slack (5 minutes)
```
URL: https://api.slack.com/apps
Action: Create app → Enable webhooks → Copy URL
n8n: Create credential "slack-credentials"
Cost: Free
```

---

## 🌍 Environment Variables

```bash
# Required
DISCORD_HORROR_CHANNEL_ID=123456789012345678
AIRTABLE_BASE_ID=appXXXXXXXXXXXXXX

# Optional
WEBHOOK_ERROR_LOGGING_URL=https://your-logging-service.com/webhook
```

**Where to set**:
- Self-hosted: `.env` file or `docker-compose.yml`
- n8n Cloud: Settings → Variables

---

## 🔧 Workflow Configuration

### Schedule Settings
```json
{
  "interval": [{"field": "hours", "hoursInterval": 24}]
}
```
**Change to**:
- 12 hours → Twice daily
- 168 hours → Weekly
- Cron expression → Custom schedule

### Engagement Score Threshold
```javascript
// In "Quality Filter" node
"rightValue": 60  // Change to desired threshold
```

### AI Prompt
```javascript
// In "AI Content Enhancer" node
// Edit the "content" field to customize prompts
```

---

## ✅ Pre-Flight Checklist

### Before First Run
- [ ] All 6 credentials created in n8n
- [ ] Environment variables set
- [ ] Workflow imported
- [ ] Workflow saved (Ctrl+S)
- [ ] Test execution successful

### Before Production Deployment
- [ ] Error trigger tested
- [ ] Timeouts configured (all API nodes)
- [ ] Idempotency keys working
- [ ] Retry logic enabled
- [ ] Team notified
- [ ] Monitoring set up

---

## 🐛 Troubleshooting Quick Fixes

### Workflow Not Running
```bash
# Check workflow is activated (toggle ON)
# Check schedule settings
# Check n8n instance is running
```

### YouTube Upload Fails
```bash
# Re-authenticate OAuth token
# Check video file size (< 256GB)
# Verify API quota not exceeded
```

### OpenAI Timeout
```bash
# Increase timeout to 60s
# Check OpenAI API status
# Verify account has credits
```

### Duplicate Posts
```bash
# Verify idempotency keys generated
# Check deduplication node logic
# Test with same content twice
```

### Discord Bot Not Working
```bash
# Verify bot token is valid
# Check bot has permissions
# Verify channel ID is correct
```

---

## 📊 Performance Metrics

### Expected Execution Time
```
RSS Feed:         ~2 seconds
Processing:       ~1 second
AI Enhancement:   ~5-10 seconds
YouTube Upload:   ~10-30 seconds
Social Posts:     ~5 seconds each
────────────────────────────
Total:            ~20-50 seconds
```

### Monthly Cost Estimate
```
n8n Cloud:        $20.00 (or $0 self-hosted)
OpenAI:           $0.30-1.50
YouTube:          Free
Twitter:          Free (50/day)
Discord:          Free
Airtable:         Free (1,000 records)
Slack:            Free
────────────────────────────
Total:            ~$20-22/month
```

---

## 🔍 Node Descriptions

| Node | Purpose | Timeout |
|------|---------|---------|
| Schedule Trigger | Daily execution | N/A |
| Horror RSS Feed | Fetch content | 10s |
| Process Horror Content | Extract & score | N/A |
| Quality Filter | Filter by score | N/A |
| Deduplication Check | Prevent duplicates | N/A |
| AI Content Enhancer | Generate titles/descriptions | 30s |
| Prepare YouTube Data | Format for upload | N/A |
| YouTube Upload | Post to YouTube | 60s |
| Fetch Horror Media | Download media | 15s |
| Prepare Tweet | Format tweet | N/A |
| Twitter Post | Post to Twitter | 20s |
| Discord Notification | Notify community | 10s |
| Log Success | Track analytics | N/A |
| Airtable Catalog | Store content | 15s |
| Error Trigger | Catch errors | N/A |
| Format Error | Format error details | N/A |
| Slack Error Alert | Send error notifications | 10s |
| Log Error to Webhook | Log errors externally | 10s |

---

## 🎯 Common Customizations

### Change RSS Feed Source
```json
// In "Horror RSS Feed" node
"url": "https://your-horror-feed.com/rss"
```

### Adjust AI Creativity
```json
// In "AI Content Enhancer" node
"options": {
  "temperature": 0.8  // 0 = serious, 2 = very creative
}
```

### Add More Tags
```javascript
// In "Process Horror Content" node
// Add to horrorKeywords array
const horrorKeywords = [
  'horror', 'scary', 'your-custom-tag'
];
```

### Change Privacy Status
```json
// In "YouTube Upload" node
"privacyStatus": "unlisted"  // or "private"
```

### Disable Social Posts
```json
// Remove connection from "Quality Filter" to "Fetch Horror Media"
```

---

## 📱 Monitoring Commands

### Check Execution Logs
```bash
# Self-hosted
docker logs n8n --tail 100 -f

# n8n Cloud
# View in UI: Executions → Workflow History
```

### Test API Credentials
```bash
# OpenAI
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_KEY"

# YouTube
# Test in n8n UI → Credentials → Test
```

### Check Workflow Status
```bash
# Via n8n API
curl https://your-n8n.com/rest/workflows/active \
  -H "Authorization: Bearer YOUR_KEY"
```

---

## 🆘 Emergency Procedures

### Stop Workflow Immediately
```bash
# Via UI: Toggle workflow OFF
# Via API:
curl -X PATCH "https://your-n8n.com/rest/workflows/WORKFLOW_ID" \
  -H "Content-Type: application/json" \
  -d '{"active": false}' \
  -H "Authorization: Bearer YOUR_KEY"
```

### Delete Erroneous Posts
```bash
# YouTube: Delete via YouTube Studio
# Twitter: Delete via Twitter interface
# Discord: Delete message normally
```

### Rollback to Previous Version
```bash
# Import previous workflow version
# Re-configure credentials (if needed)
# Test before activating
```

---

## 📚 Additional Resources

### Official Documentation
- n8n: https://docs.n8n.io
- OpenAI: https://platform.openai.com/docs
- YouTube API: https://developers.google.com/youtube/v3
- Twitter API: https://developer.twitter.com/en/docs

### Community Support
- n8n Community: https://community.n8n.io
- n8n Discord: https://discord.gg/n8n
- Stack Overflow: [tag:n8n]

### Training Resources
- n8n Tutorials: https://www.youtube.com/c/n8nio
- n8n Academy: https://academy.n8n.io
- n8n Templates: https://n8n.io/workflows

---

## 🎓 Best Practices

### Security
- ✅ Never commit credentials to git
- ✅ Rotate API keys monthly
- ✅ Use environment variables for secrets
- ✅ Limit API permissions to minimum required

### Performance
- ✅ Set appropriate timeouts on all API calls
- ✅ Use retry logic with exponential backoff
- ✅ Implement idempotency for all writes
- ✅ Monitor API quota usage

### Reliability
- ✅ Test error handling regularly
- ✅ Monitor execution logs daily
- ✅ Keep workflow documentation updated
- ✅ Have rollback plan ready

---

## 📞 Support

**Conceived by Romuald Członkowski - https://www.aiadvisors.pl/en**

For issues specific to this workflow:
1. Check troubleshooting section above
2. Review full testing guide
3. Consult n8n community forums
4. Check n8n documentation

---

*Last Updated: 2025-01-22*
*Version: 2.0 (Improved)*
