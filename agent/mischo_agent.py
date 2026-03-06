import asyncio, websockets, ssl, pyautogui, mss, cv2, numpy as np, base64, json

CERT_FILE = "cert.pem"
KEY_FILE = "key.pem"

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)

async def handler(ws):
    async for msg in ws:
        data = json.loads(msg)
        action = data.get("action")
        if action=="screenshot":
            with mss.mss() as sct:
                monitor = sct.monitors[1]
                img = np.array(sct.grab(monitor))
                _, buffer = cv2.imencode(".jpg", img)
                b64_image = base64.b64encode(buffer).decode()
                await ws.send(json.dumps({"type":"screenshot","data":b64_image}))
        elif action=="click":
            pyautogui.click()
        elif action=="move_mouse":
            pyautogui.moveTo(data["x"], data["y"])
        elif action=="type":
            pyautogui.typewrite(data.get("text",""))

async def main():
    async with websockets.serve(handler, "0.0.0.0", 8080, ssl=ssl_context):
        await asyncio.Future()

if __name__=="__main__":
    asyncio.run(main())
