# mischo_agent.py
import asyncio
import websockets
import pyautogui
import mss
import cv2
import numpy as np
import base64
import json

async def handler(websocket, path):
    async for message in websocket:
        data = json.loads(message)
        if data["action"] == "screenshot":
            with mss.mss() as sct:
                monitor = sct.monitors[1]
                img = np.array(sct.grab(monitor))
                _, buffer = cv2.imencode(".jpg", img)
                b64_image = base64.b64encode(buffer).decode("utf-8")
                await websocket.send(json.dumps({"type": "screenshot", "data": b64_image}))
        elif data["action"] == "move_mouse":
            x, y = data["x"], data["y"]
            pyautogui.moveTo(x, y)

async def main():
    async with websockets.serve(handler, "0.0.0.0", 8080):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
