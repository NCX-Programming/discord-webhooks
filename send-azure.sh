#!/bin/bash

if [ -z "$2" ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DS-Homebrew/discord-webhooks" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="Passed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/azure-logo.png"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="Failed"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/azure-logo.png"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="Status Unknown"
    AVATAR="https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/azure-logo.png"
    ;;
esac

AUTHOR_NAME="$(git log -1 "$BUILD_SOURCEVERSION" --pretty="%aN")"
COMMITTER_NAME="$(git log -1 "$BUILD_SOURCEVERSION" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$BUILD_SOURCEVERSION" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "$BUILD_SOURCEVERSION" --pretty="%b")"
SOURCEBRANCH=${BUILD_SOURCEBRANCH##*/}

if [ "$AUTHOR_NAME" == "$COMMITTER_NAME" ]; then
  CREDITS="$AUTHOR_NAME authored & committed"
else
  CREDITS="$AUTHOR_NAME authored & $COMMITTER_NAME committed"
fi

# if [[ $SYSTEM_PULLREQUEST_PULLREQUESTNUMBER != false ]]; then
#   URL="https://github.com/$REPOSITORY_NAME/pull/$SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"
# else
#   URL=""
# fi

TIMESTAMP=$(date --utc +%FT%TZ)
if [ $IMAGE = "" ]; then
  WEBHOOK_DATA='{
    "username": "",
    "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/azure-logo.png",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"v$CURRENT_DATE"' '"$STATUS_MESSAGE"' - '"$REPOSITORY_NAME"'",
        "url": "'"https://dev.azure.com/universal-team/Builds/_build/results?buildId=$BUILD_BUILDID"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${BUILD_SOURCEVERSION:0:7}\`](https://github.com/$REPOSITORY_NAME/commit/$BUILD_SOURCEVERSION)"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`$SOURCEBRANCH\`](https://github.com/$REPOSITORY_NAME/tree/$SOURCEBRANCH)"'",
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
    "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/azure-logo.png",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Build '"v$CURRENT_DATE"' '"$STATUS_MESSAGE"' - '"$REPOSITORY_NAME"'",
        "url": "'"https://dev.azure.com/universal-team/Builds/_build/results?buildId=$BUILD_BUILDID"'",
        "icon_url": "'$AVATAR'"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`${BUILD_SOURCEVERSION:0:7}\`](https://github.com/$REPOSITORY_NAME/commit/$BUILD_SOURCEVERSION)"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`$SOURCEBRANCH\`](https://github.com/$REPOSITORY_NAME/tree/$SOURCEBRANCH)"'",
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

(curl --fail --progress-bar -A "Azure-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$2" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
