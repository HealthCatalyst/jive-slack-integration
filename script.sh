#!/bin/bash
# Variables passed in from 1234.json
# Does not post voting actions. To post votes, add `voted:on`` under `Verbs` section and remove `Remove votes by popular demand` code (and fix filenames in lines before and after).

# Polling interval
after=`date --date="5 minutes ago" +%FT%T.%3N`
before=`date +%FT%T`

if [ -z "$1" ]
  then filter=""
  else filter="&"$1
fi

# Get objects
curl -XGET -u "username:password" "https://<your jive instance>/api/core/v3/places/"$space"/activities?after=${after}%2D0000${filter}&count=100&directive=silent" > "$space".json

# Focus on relevant keys/values
jq -s '.[] | .list[]' <"$space".json >"$space"-1.json

jq '{ displayName: .actor.displayName, personUrl: .actor.url, verb, icon: .jive.iconCss, title, url, text: .object.summary }' <"$space"-1.json >"$space"-2.json

jq -s . <"$space"-2.json >"$space"-4.json

# Verbs
sed -i -e 's|jive:replied|replied to|g;' "$space"-4.json
sed -i -e 's|jive:created|posted|g;' "$space"-4.json
sed -i -e 's|jive:modified|modified|g;' "$space"-4.json
sed -i -e 's|jive:commented|commented on|g;' "$space"-4.json

# Icons
sed -i -e 's|jive-icon-discussion-question|:jive_question:|g;' "$space"-4.json
sed -i -e 's|jive-icon-discussion-correct|:jive_correct:|g;' "$space"-4.json
sed -i -e 's|jive-icon-discussion-question|:jive_question:|g;' "$space"-4.json
sed -i -e 's|jive-icon-discussion|:jive_discuss:|g;' "$space"-4.json
sed -i -e 's|jive-icon-poll-comment|:jive_poll_comment:|g;' "$space"-4.json
sed -i -e 's|jive-icon-poll|:jive_poll:|g;' "$space"-4.json
sed -i -e 's|jive-icon-blog-comment|:jive_blog_comment:|g;' "$space"-4.json
sed -i -e 's|jive-icon-blog|:jive_blog:|g;' "$space"-4.json
sed -i -e 's|jive-icon-med jive-icon-video-comment|:jive_vid_comment:|g;' "$space"-4.json
sed -i -e 's|jive-icon-video|:jive_vid:|g;' "$space"-4.json
sed -i -e 's|jive-icon-med jive-icon-event-comment|:jive_event_comment:|g;' "$space"-4.json
sed -i -e 's|jive-icon-med jive-icon-event|:jive_event:|g;' "$space"-4.json
sed -i -e 's|jive-icon-med jive-icon-idea|:jive_idea:|g;' "$space"-4.json
sed -i -e 's|jive-icon-comment|:jive_message:|g;' "$space"-4.json
sed -i -e 's|jive-icon-document-upload|:jive_zip:|g;' "$space"-4.json
sed -i -e 's|jive-icon-document-comment|:jive_doc_comment:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-document|:jive_word:|g;' "$space"-4.json
sed -i -e 's|jive-icon-document|:jive_doc:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-generic|:jive_file:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-presentation|:jive_pres:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-compressed|:jive_zip:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-acrobat|:jive_pdf:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-image|:jive_image:|g;' "$space"-4.json
sed -i -e 's|jive-icon-doctype-spreadsheet|:jive_file:|g;' "$space"-4.json

# Assemble Slack post in Slack message format https://api.slack.com/docs/messages
jq --compact-output '.[] | {text: ("<" + .personUrl +  "|" + .displayName + "> " + .verb + " " + .icon  + " <" + .url+ "|" + .title + ">" ), attachments: [{ color: "#3399ff", text }] }' <"$space"-4.json >"$space"-5.json

# Filter out vote actions
sed -e '/jive:voted/d' <"$space"-5.json >"$space"-6.json

# Fix single quotes that break cURL command
sed -i -e 's|'\''|'"'\"\'\"'"'|g;' "$space"-6.json

# Fix space
sed -i -e 's|&#160;| |g;' "$space"-6.json

# Fix Github wiki link dot
sed -i -e 's|&#183;|-|g;' "$space"-6.json

# Turn into cURL command to post to Slack
sed -i -e "s|^|curl -X POST -H 'Content-type: application/json' --data '|g;" "$space"-6.json
sed -i -e "s|$|' {"$slack"}|g;" "$space"-6.json

# Remove duplicates
awk '!x[$0]++' <"$space"-6.json >"$space"-7.json
awk '$1=$1' <"$space"-7.json >"$space"-8.json

# Re-order so most recent activity posts last
tac <"$space"-8.json >"$space"-9.json

# Post to Slack
./"$space"-9.json

# Remove Slack posts so they won't post more than once
rm "$space"-[0-9].json
rm "$space".json