#!/bin/bash

# This script needs to be dropped into the /boot/config/plugins/dynamix/notifications/agents/ directory. If it does not exist, create it.
# You then need to enable agent notifications in Unraid.

# ntfy user access token. Example: tk_01klhatkahiuh29yuaghtikjagtikjaw
NTFYTOKEN=

# ntfy url. Example: notify.yourdomain.com
NTFYURL=

# Icon to be displayed in the notification
NTFYICON="https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/unraid.png"

# Set this to the url of your unraid web interface. Example: "https://yourserverhostname.lab"
UNRAIDURL=

# Fixes the '\n' line breaks from not being rendered properly on the mobile app notifications...
TEMP=${CONTENT}
NEWCONTENT="${TEMP//\\n/$'\n'}"

if [ "${IMPORTANCE}" = "alert" ]; then
  curl -H "Title: ${SUBJECT}" \
 -u :$NTFYTOKEN \
 -H "Priority: 5" \
 -H "X-Tags: warning" \
 -H "Icon: $NTFYICON" \
 -H "Tags: unRAID" \
 -d "**Event:**
${EVENT}
**Description:**
${DESCRIPTION}
**Time:**
$(date '+%Y-%m-%d %H:%M:%S')

${NEWCONTENT}" \
 -H "Markdown: yes" \
 -H "Actions: view, WebUI, $UNRAIDURL; \
              view, Logs, $UNRAIDURL/Tools/Syslog" \
  $NTFYURL
fi

if [ "${IMPORTANCE}" = "warning" ]; then
  curl -H "Title: ${SUBJECT}" \
 -u :$NTFYTOKEN \
 -H "Priority: 4" \
 -H "X-Tags: triangular_flag_on_post" \
 -H "Icon: $NTFYICON" \
 -H "Tags: unRAID" \
 -d "**Event:**
${EVENT}
**Description:**
${DESCRIPTION}
**Time:**
$(date '+%Y-%m-%d %H:%M:%S')

${NEWCONTENT}" \
 -H "Markdown: yes" \
 -H "Actions: view, WebUI, $UNRAIDURL; \
              view, Logs, $UNRAIDURL/Tools/Syslog" \
  $NTFYURL
fi

if [ "${IMPORTANCE}" = "normal" ]; then
  curl -H "Title: ${SUBJECT}" \
 -u :$NTFYTOKEN \
 -H "Priority: 1" \
 -H "Icon: $NTFYICON" \
 -H "Tags: unRAID" \
 -d "**Event:**
${EVENT}
**Description:**
${DESCRIPTION}
**Time:**
$(date '+%Y-%m-%d %H:%M:%S')

${NEWCONTENT}" \
 -H "Markdown: yes" \
  $NTFYURL
fi