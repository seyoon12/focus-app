from fastapi import FastAPI, Request

app = FastAPI()

@app.post("/kakao-webhook")
async def kakao_webhook(request: Request):
    body = await request.json()
    utter = body["userRequest"]["utterance"]

    if "예" in utter or "yes" in utter.lower():
        return {
            "version": "2.0",
            "template": {
                "outputs": [
                    {"simpleText": {"text": "습관 완료로 기록할게요! ✅"}}
                ]
            }
        }

    elif "아니요" in utter or "no" in utter.lower():
        return {
            "version": "2.0",
            "template": {
                "outputs": [
                    {"simpleText": {"text": "괜찮아요, 다시 도전해봐요! 💪"}}
                ]
            }
        }

    return {
        "version": "2.0",
        "template": {
            "outputs": [
                {"simpleText": {"text": "오늘의 습관 완료하셨나요? 😊"}}
            ],
            "quickReplies": [
                {"label": "예", "action": "message", "messageText": "예"},
                {"label": "아니요", "action": "message", "messageText": "아니요"},
            ]
        }
    }
