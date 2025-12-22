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
        "embeds": [
            {
                "title": "S3 檔案上傳通知",
                "description": f"有新檔案更新囉!",
                "fields": [
                    {
                        "name": "檔案名稱",
                        "value":str(key),
                        "inline": False
                    },
                    {
                        "name": "檔案大小",
                        "value": str(record['s3']['object']['size']/1024) + ' KB',
                        "inline": False
                    },
                    {
                        "name": "S3 bucket 名稱",
                        "value": str(bucket),
                        "inline": False
                    }
                ],
                "color": 5814783,
                "footer": {
                    "text": "由 AWS Lambda 自動發送"
                },
                "timestamp": record['eventTime']
            }
        ]
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
