#!/bin/bash

if [ -z "$2" ]; then
  echo -e "WARNING!!\nYou need to pass the ${{ secrets.WEBHOOK_URL }} environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DS-Homebrew/discord-webhooks" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="Passed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="Failed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="Status Unknown"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png"
    ;;
esac

AUTHOR_NAME="$(git log -1 "${{ github.sha }}" --pretty="%aN")"
COMMITTER_NAME="$(git log -1 "${{ github.sha }}" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "${{ github.sha }}" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "${{ github.sha }}" --pretty="%b")"
SOURCEBRANCH=${{ github.sha }}

if [ "${{ github.actor }}" == "$COMMITTER_NAME" ]; then
  CREDITS="${{ github.actor }} authored & committed"
else
  CREDITS="${{ github.actor }} authored & someone else committed"
fi

TIMESTAMP=$(date --utc +%FT%TZ)
if [ $IMAGE = "" ]; then
  WEBHOOK_DATA='{
    "username": "",
    "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"${{ github.sha }}"' '"${{ github.event_name }}"' - '"${{ github.repository }}"'",
        "url": "'"https://github.com/${{ github.repository}}/commit/${{ github.sha }}/checks"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${{ github.event_name }}"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${{ github.sha }}\`](https://github.com/${[ github.repository }}/commit/${{ github.sha }})"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`${{ github.ref }}`](https://github.com/${{ github.repository }}/tree/${{ github.ref }})"'",
          "inline": true
        },
        {
          "name": "Release",
          "value": "'"[\`v$CURRENT_DATE\`](https://github.com/Universal-Team/extras/releases/tag/v$CURRENT_DATE)"'",
          "inline": true
        }
      ],
      "timestamp": "'"$TIMESTAMP"'"
    } ]
  }'
else
  WEBHOOK_DATA='{
    "username": "",
    "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"${{ github.sha }}"' '"${{ github.event_name }}"' - '"${{ github.repository }}"'",
        "url": "'"https://github.com/${{ github.repository}}/commit/${{ github.sha }}/checks"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${{ github.event_name }}"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${{ github.sha }}\`](https://github.com/${{ github.repository }}/commit/${{ github.sha }})"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`${{ github.ref }}\`](https://github.com/${{ github.repository }}/tree/${{ github.ref }})"'",
          "inline": true
        },
        {
          "name": "Release",
          "value": "'"[\`v$CURRENT_DATE\`](https://github.com/Universal-Team/extras/releases/tag/v$CURRENT_DATE)"'",
          "inline": false
        }
      ],
      "image": {
        "url": "'"$IMAGE"'"
      },
      "timestamp": "'"$TIMESTAMP"'"
    } ]
  }'
fi

(curl --fail --progress-bar -A "Github-Actions-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$2" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
