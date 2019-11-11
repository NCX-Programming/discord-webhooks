#!/bin/bash

if [ -z "$1" ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DS-Homebrew/discord-webhooks" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

EMBED_COLOR=51330
AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
UPDATED_FILES="$(git diff-tree --no-commit-id --name-only -r HEAD)"

if [ $UPDATED_FILES == "info/scriptInfo.json" ]; then
  UPDATED_FILES="$(git diff-tree --no-commit-id --name-only -r HEAD~1)"
fi

TIMESTAMP=$(date --utc +%FT%TZ)
WEBHOOK_DATA='{
  "username": "Github Actions",
  "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png",
  "embeds": [ {
    "color": '$EMBED_COLOR',
    "author": {
      "name": "Scripts updated!",
      "url": "https://raw.githubusercontent.com/Universal-Team/extras/scripts/info/scriptInfo.json",
      "icon_url": "'$AVATAR'"
    },
    "description": "'"$UPDATED_FILES"'",
    "timestamp": "'"$TIMESTAMP"'"
  } ]
}'

(curl --fail --progress-bar -A "Github-Actions-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$1" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
