import json
import urllib.request
import os
import urllib.request
print(urllib.request.urlopen("https://api.ipify.org").read())
WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL")

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))
    print("DISCORD_WEBHOOK_URL:", WEBHOOK_URL)
    # 取得 S3 物件資訊
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    message = {
        "content": f"Hello from curl!"
    }

    data = json.dumps(message).encode("utf-8")

    req = urllib.request.Request(
        WEBHOOK_URL,
        data=data,
        headers={'Content-Type': 'application/json',
                 "User-Agent": "lambda-bot"},
        method='POST'
    )

    try:
        with urllib.request.urlopen(req) as res:
            print("Discord Webhook Response:", res.read().decode("utf-8"))
    except Exception as e:
        print("Error sending Discord webhook:", e)

    return {"status": "ok"}
