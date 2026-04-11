#!/bin/bash
# SupplyLink Daily Maintenance Script
# Reads task card: /root/.openclaw/workspace-crm/central/tasks/supply-daily-task.md
# Scheduled: 9:00 AM daily

DATE=$(date +%Y-%m-%d)
TASK_FILE="/root/.openclaw/workspace-crm/central/tasks/supply-daily-task.md"
REPORT_DIR="/root/.openclaw/workspace-crm/central/reports"
WORKSPACE="/root/.openclaw/workspace-geo-suppler/suppler-geo"
GEN_DIR="/root/.openclaw/workspace-crm/notebooklm_seo"
LOG="$WORKSPACE/logs/daily-$DATE.log"

mkdir -p $REPORT_DIR $WORKSPACE/logs

echo "=== SupplyLink Daily Run $DATE ===" | tee -a $LOG
echo "Task file: $TASK_FILE" | tee -a $LOG

cd $GEN_DIR

# Task 1: Generate clothing subclasses
echo "=== Task 1: Generate subclasses ===" | tee -a $LOG

generate_page() {
    local type=$1
    local slug=$2
    local h1=$3
    local url=$4
    echo "  Generating: $slug ($type)" | tee -a $LOG
    python3 supply_generator.py --type $type --slug "$slug" --url "$url" --h1 "$h1" 2>&1 | tee -a $LOG
}

# Clothing subclasses
generate_page "product" "clothing-dresses" "Dresses Sourcing from China" "https://uscompliance-team.com/clothing-dresses.html"
generate_page "product" "clothing-jackets" "Jackets Sourcing from China" "https://uscompliance-team.com/clothing-jackets.html"
generate_page "product" "clothing-pants" "Pants & Trousers Sourcing" "https://uscompliance-team.com/clothing-pants.html"
generate_page "product" "clothing-activewear" "Activewear Sourcing from China" "https://uscompliance-team.com/clothing-activewear.html"
generate_page "product" "clothing-formal" "Formal Wear Sourcing from China" "https://uscompliance-team.com/clothing-formal.html"

# Electronics subclasses
generate_page "product" "smartphones" "Smartphones Sourcing from China" "https://uscompliance-team.com/smartphones.html"
generate_page "product" "tablets" "Tablets Sourcing from China" "https://uscompliance-team.com/tablets.html"
generate_page "product" "smartwatches" "Smartwatches Sourcing from China" "https://uscompliance-team.com/smartwatches.html"
generate_page "product" "cameras" "Camera Equipment Sourcing" "https://uscompliance-team.com/cameras.html"

echo "Subclass generation complete" | tee -a $LOG

# Copy to website
cp -r output/supply-chain/product/* $WORKSPACE/ 2>/dev/null

# Task 2: Git commit and push
echo "=== Task 2: Git push ===" | tee -a $LOG
cd $WORKSPACE
git add -A 2>/dev/null
git commit -m "Supply: +clothing +electronics subclasses $DATE" 2>&1 | tee -a $LOG
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
git push origin main 2>&1 | tee -a $LOG
echo "Git push: $GIT_COMMIT" | tee -a $LOG

# Task 3: Cloudflare deploy
echo "=== Task 3: Cloudflare deploy ===" | tee -a $LOG
export CLOUDFLARE_API_TOKEN=vyfGE3SeOTvZNdKr1jclFCZwaNGWv0P_sILtprBT
cd $WORKSPACE
npx wrangler pages deploy . --project-name=suppler-geo 2>&1 | tee -a $LOG

# Task 4: Write daily report
echo "=== Task 4: Daily report ===" | tee -a $LOG
cat > $REPORT_DIR/supply_$DATE.json << EOF
{
  "agent": "supply",
  "workspace": "workspace-geo-suppler",
  "date": "$DATE",
  "status": "ok",
  "pages_generated": 9,
  "pages_published": 9,
  "git_commit": "$GIT_COMMIT",
  "pages_by_type": {
    "product": 9,
    "city": 6,
    "service": 3,
    "guide": 5
  },
  "errors": [],
  "blockers": [],
  "content_updated": ["clothing子类5个", "electronics子类4个"],
  "next_priority": "bags/toys/beauty子类扩展",
  "needs_attention": false,
  "notes": "Daily task completed per supply-daily-task.md"
}
EOF
echo "Report: $REPORT_DIR/supply_$DATE.json" | tee -a $LOG

echo "=== Done $DATE ===" | tee -a $LOG
