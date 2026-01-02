#!/bin/bash

# Setup script for automatic file indexing via cron

echo "Setting up automatic file indexing..."

# Create the cron entry
CRON_CMD="/Users/andrew/.config/scripts/index_home.sh --background"
CRON_SCHEDULE="0 */4 * * *"  # Run every 4 hours

# Check if cron entry already exists
if crontab -l 2>/dev/null | grep -q "index_home.sh"; then
    echo "Cron job already exists for file indexing"
else
    # Add the cron job
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $CRON_CMD") | crontab -
    echo "Added cron job to run indexing every 4 hours"
fi

echo ""
echo "Current cron jobs:"
crontab -l | grep index_home.sh

echo ""
echo "To manually edit cron jobs: crontab -e"
echo "To remove the indexing cron job: crontab -l | grep -v index_home.sh | crontab -"