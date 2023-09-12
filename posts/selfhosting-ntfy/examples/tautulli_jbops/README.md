# kill_stream.py
><--- BEGIN DISCLAIMER --->
>
>This file was edited to support ntfy json notifications via Tautulli to a private instance of ntfy.sh. 
>**DO NOT LOG ISSUES WITH THE ORIGINAL AUTHORS AS THIS SCRIPT HAS BEEN MODIFIED FROM THE ORIGINAL FOR A SINGLE PURPOSE.**
>
><--- END DISCLAIMER --->

[Original file](https://github.com/blacktwin/JBOPS/blob/master/killstream/kill_stream.py)

So after doing a bunch of googling, asking in ntfy's discord, and searching all three repositories [tautulli, ntfy, jbops]. I ended up having to modify the kill_stream.py script to make it work with ntfy properly. I could be missing something, aka PEBKAC, but I noticed that JSON data set in the "Data" tab for a webhook agent was being overwritten by the script's own JSON data. Especially since I am using a private instance of ntfy that has a default auth policy of `deny-all` which requires the `Authorization` header to be specified.

Basically what I did was create a new rich_notify definition for ntfy called `def send_ntfy`:

```py
# kill_stream.py
    def send_ntfy(self, title, msg, message):

        AUTH = "Bearer " + str(NTFY_TOKEN)
        LOGURL = str(TAUTULLI_PUBLIC_URL) + "logs"


        ntfy_subject = {
            "Authorization": AUTH
        }

        ntfy_message = {
            "topic": "plex",
            "icon": TAUTULLI_ICON,
            "tags": ["tautulli"],
            "priority": 3,
            "title": title,
            "message": msg,
            "actions": [{ "action": "view", "label": "Tautulli Logs", "url": LOGURL }]
        }

        ntfy_subject = json.dumps(ntfy_subject, sort_keys=True,
                                     separators=(',', ': '))

        ntfy_message = json.dumps(ntfy_message, sort_keys=True,
                                     separators=(',', ': '))
        self.send(subject=ntfy_subject, body=ntfy_message)
```

and dropped it in between `def send_discord` and `def send_slack`. This creates the proper json formatting for the ntfy json header (ntfy_subject) and body (ntfy_message). I then modified the argument parser to include a new option called `--concurrent`. This can be specified when using `kill_stream.py` to terminate multiple streams from unique IPs.

```py
# kill_stream.py
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Killing Plex streams from Tautulli.")
    parser.add_argument('--jbop', required=True, choices=SELECTOR,
                        help='Kill selector.\nChoices: (%(choices)s)')
    parser.add_argument('--userId', type=int,
                        help='The unique identifier for the user.')
    parser.add_argument('--username', type=arg_decoding,
                        help='The username of the person streaming.')
    parser.add_argument('--sessionId',
                        help='The unique identifier for the stream.')
    parser.add_argument('--notify', type=int,
                        help='Notification Agent ID number to Agent to ' +
                        'send notification.')
    parser.add_argument('--limit', type=int, default=(20 * 60),  # 20 minutes
                        help='The time session is allowed to remain paused.')
    parser.add_argument('--interval', type=int, default=30,
                        help='The seconds between paused session checks.')
    parser.add_argument('--killMessage', nargs='+', type=arg_decoding,
                        help='Message to send to user whose stream is killed.')
    parser.add_argument('--richMessage', type=arg_decoding, choices=RICH_TYPE,
                        help='Rich message type selector.\nChoices: (%(choices)s)')
    parser.add_argument('--serverName', type=arg_decoding,
                        help='Plex Server Name')
    parser.add_argument('--plexUrl', type=arg_decoding,
                        help='URL to plex media')
    parser.add_argument('--posterUrl', type=arg_decoding,
                        help='Poster URL of the media')
    parser.add_argument('--richColor', type=arg_decoding,
                        help='Color of the rich message')
    parser.add_argument("--debug", action='store_true',
                        help='Enable debug messages.')
    parser.add_argument("--concurrent", action='store_true',
                        help='Set concurrent kill message for ntfy')

    opts = parser.parse_args()
```

I then created a new VAR for the ntfy access token: `NTFY_AUTH_TOKEN` with a default empty string. Then set `NTFY_TOKEN` to pull from an environment variable value that gets added to Tautulli's docker compose file.

```py
# kill_stream.py
TAUTULLI_URL = ''
TAUTULLI_APIKEY = ''
TAUTULLI_PUBLIC_URL = ''
TAUTULLI_URL = os.getenv('TAUTULLI_URL', TAUTULLI_URL)
TAUTULLI_PUBLIC_URL = os.getenv('TAUTULLI_PUBLIC_URL', TAUTULLI_PUBLIC_URL)
TAUTULLI_APIKEY = os.getenv('TAUTULLI_APIKEY', TAUTULLI_APIKEY)
TAUTULLI_ENCODING = os.getenv('TAUTULLI_ENCODING', 'UTF-8')
VERIFY_SSL = False
NTFY_AUTH_TOKEN = ''
NTFY_TOKEN = os.getenv('NTFY_AUTH_TOKEN', NTFY_AUTH_TOKEN)
```

```yml
# docker-compose.yml env
    environment:
      TZ: America/New_York
      NTFY_AUTH_TOKEN: "your-access-token-here"
```

I then updated the `def rich_notify` function to include the `--concurrent` arg as well as edited the `kill_type` section for updated ntfy messaging.

```py
def rich_notify(notifier_id, rich_type, color=None, kill_type=None, server_name=None,
                plex_url=None, poster_url=None, message=None, stream=None, tautulli=None, concurrent=None):

                <...>

    # Set ntfy message based on --concurrent arg.
    if opts.concurrent is True:
        msg = "Killstream terminated {}'s stream for account sharing".format(stream.friendly_name)
    else:
        msg = "Killstream terminated {}'s stream for transcoding 4K media remotely.".format(stream.friendly_name)

    if kill_type == 'Stream':
        title = "Killed {}'s stream.".format(stream.friendly_name)
        footer = '{} | Kill {}'.format(server_name, kill_type)

    elif kill_type == 'Paused':
        title = "Killed {}'s paused stream.".format(stream.friendly_name)
        footer = '{} | Kill {}'.format(server_name, kill_type)
        msg = "Killstream terminated {}'s paused stream after 30 minutes.".format(stream.friendly_name)

                <...>

    if rich_type == 'ntfy':
        notification.send_ntfy(title, msg, message)
```

## How to use
> I use this script to do 3 things. Kill 4k remote transcodes, kill 2+ unique IP streams, and kill streams paused after 30mins with message.

1. Copy `kill_stream.py` to a directory that Tautulli can see.
2. Add a new webhook notification agent to Tautulli and set the url to the base url for your ntfy instance. Set method to POST. Give it a description, save, and close the edit window. Do not add triggers or modify the Conditions / Data tabs. *yet..*
3. Next create another notification agent for scripts that points to this kill_stream.py script. Call it `Kill 4K remote transcodes` Under the arguments for:
    - Playback Start: 
    `--jbop stream --username {username} --sessionId {session_id}  --killMessage 'your message here' --notify id-of-agent-in-step-2 --richMessage ntfy`
    - Transcode Decision Change: 
    `--jbop stream --username {username} --sessionId {session_id}  --killMessage 'your message here' --notify id-of-agent-in-step-2 --richMessage ntfy`
4. Set triggers for play start and transcode decision change.
5. Set Conditions to:
   - "Stream Local" `is not` "1"
   - Video Resolution `is` "4K OR 2160 OR 3840"
   - "Transcode Decision" `is` "transcode"
   - Logic: `{1} and {2} and {3}`
6. Save & close
7. Repeat step two but call it `kill after 30m pause` and set the following:
    - Triggers:
        - Playback Pause [x]
    - Arguments:
        - Playback Pause: `--jbop paused --interval 30 --limit 900 --sessionId {session_id} --killMessage "Your stream was paused for over 30 minutes and has automatically been stopped. To continue viewing, please restart your stream from the selected media's info screen." --notify id-of-agent-in-step-2 --richMessage ntfy`
    - Conditions:
        - "Stream Local" `is not` "1"
8. Save and close
9. Finally create another agent, same as step 2&6, but call it `kill 2+ unique ip streams` and set the following:
    - Triggers:
        - User Concurrent Streams [x]
    - Arguments:
        - User Concurrent Streams: `--jbop stream --username {username} --sessionId {session_id} --killMessage 'Sharing accounts with people outside your home is not allowed.' --notify id-of-agent-in-step-2 --richMessage ntfy --concurrent`
10. Save and close

**Extra**: If you want you can also add Tautulli & Plex update notifications to the `ntfy` webhook agent. This can be done in the "Data" tab. Then active the triggers for updates.