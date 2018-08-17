# Jive-Slack integration
This integration sends notifications about content-related activity in a Jive space or group to a Slack channel. Notifications cover:

- New questions, discussions, blog posts, documents, ideas, files, and videos
- Comments and replies to comments
- Updates to documents and uploaded files, including .zip and .pdf files

Notifications include:

- User performing the action
- Link to the user's Jive profile
- Link to the content in Jive
- Any body content up to about 325 characters (with spaces)

## Purpose
Email is the primary way Jive notifies subscribed users of Jive activity. Notifications of Jive activity in a Slack channel promote engagement from users in a shop that uses Slack more than email. No Jive-Slack integration is on the market.

## How it works
- Uses Jive's REST API to extract the past five minutes of user activity related to content
- Formats the data into human-readable text and Slack's messaging format
- Sends the message via cURL to a Slack incoming webhook integration for a specified Slack channel
- When triggered every five minutes, provides a near-real-time feed of activity

## Requirements
- Bash (including sed and awk)
- JQ

## Steps
- Add your username, password, and Jive instance in `script.sh`. (If your account is federated, create and use an unfederated user account.)
- _Places_ include groups and spaces. Each group and space has a `placeID`. Find your `placeID`(s): `https://<your jive instance>/api/core/v3/places?filter=type(space,group)&fields=-resources,placeID,displayName,-id,-typeCode&count=100&startIndex=0`
- Add the placeID(s) in `run.sh` and `1234.sh`.
- Set up a Slack incoming webhook to a specified Slack channel: `https:/<your slack instance>.slack.com/apps/manage/custom-integrations`
- Add the Slack webhook URL in `1234.sh`.
- To add integrations of multiple places to multiple Slack channels, add a new version of `1234.sh` for each `placeID`. Add a new `placeID` entry to `run.sh`.

### Load icons as custom Emoji in Slack
Go to `https://<your slack instance>.slack.com/customize/emoji`. Upload icons named as follows:
- jive_discuss
- jive_question
- jive_correct
- jive_message
- jive_blog
- jive_blog_comment
- jive_vid
- jive_vid_comment
- jive_idea
- jive_idea_comment
- jive_file
- jive_zip
- jive_doc
- jive_doc_comment
- jive_word
- jive_pres
- jive_pdf
- jive_poll
- jive_poll_comment
- jive_event
- jive_event_comment
- jive_image

See https://community.jivesoftware.com/docs/DOC-176273 for Jive's icons.

### Set up a near-real-time activity feed
An option is to set a timer trigger in an Azure Logic App that triggers a VSTS build of this project at set intervals. The interval set in `script.sh` should match.

Include these steps in the Azure Logic App:
- Recurrence with an interval of five minutes
- Queue a new VSTS build

Include these tasks in the VSTS build:

- Install/upgrade chocolatey
- Chocolatey step: `install jq`
- Bash script step that points to `run.js`