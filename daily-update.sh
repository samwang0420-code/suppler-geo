#!/bin/bash
cd /root/.openclaw/workspace-geo-suppler/suppler-geo

# 1. Generate new blog post (if available)
if [ -f "daily-blog.js" ]; then
    node daily-blog.js
fi

# 2. Deploy to Cloudflare (if changes exist)
# Note: You'll need to set CLOUDFLARE_API_TOKEN in your environment
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    wrangler pages deploy . --project-name=suppler-geo
    echo "Deployed to Cloudflare Pages"
else
    echo "CLOUDFLARE_API_TOKEN not set. Skipping deployment."
    echo "Set it with: export CLOUDFLARE_API_TOKEN=your_token"
fi
