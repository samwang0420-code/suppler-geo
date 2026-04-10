#!/bin/bash
# Daily content update script for SupplyLink website
# Run this script to set up automatic daily updates

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

echo "Setting up daily content updates..."

# Create update script that generates content and deploys
cat > "$PROJECT_DIR/daily-update.sh" << 'EOF'
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
EOF

chmod +x "$PROJECT_DIR/daily-update.sh"

# Add to crontab (runs every day at 9 AM)
CRON_JOB="0 9 * * * $PROJECT_DIR/daily-update.sh >> /var/log/suppler-update.log 2>&1"

# Remove existing suppler cron entries and add new one
(crontab -l 2>/dev/null | grep -v "suppler-update\|daily-blog"; echo "$CRON_JOB") | crontab -

echo "✅ Daily update cron job set up!"
echo ""
echo "Current crontab:"
crontab -l | grep suppler
echo ""
echo "The script will:"
echo "1. Generate a new blog post (if topics available)"
echo "2. Deploy to Cloudflare Pages"
echo ""
echo "To run manually: $PROJECT_DIR/daily-update.sh"
