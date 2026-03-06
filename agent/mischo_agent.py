import asyncio
import websockets
import ssl
import pyautogui
import mss
import cv2
import numpy as np
import base64
import json
import os
import subprocess
import sys

# -----------------------------
# SSL-Zertifikat-Dateien
# -----------------------------
CERT_FILE = "cert.pem"
KEY_FILE = "key.pem"

# Falls die Dateien nicht existieren, erzeugen
if not os.path.exists(CERT_FILE) or not os.path.exists(KEY_FILE):
    print("SSL certificate or key not found. Generating self-signed certificate...")
    try:
        # OpenSSL command
        subprocess.run([
            "openssl", "req", "-x509", "-nodes", "-days", "365",
            "-newkey", "rsa:2048", "-keyout", KEY_FILE, "-out", CERT_FILE,
            "-subj", "/C=US/ST=State/L=City/O=Mischo/OU=Dev/CN=localhost"
        ], check=True)
        print("Self-signed certificate generated.")
    except Exception as e:
        print("Failed to generate SSL certificate:", e)
        sys.exit(1)

# SSL-Kontext
ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)

# -----------------------------
# WebSocket Handler
# -----------------------------
async def handler(ws):
    async for msg in ws:
        try:
            data = json.loads(msg)
            action = data.get("action")
            
            if action == "screenshot":
                with mss.mss() as sct:
                    monitor = sct.monitors[1]
                    img = np.array(sct.grab(monitor))
                    _, buffer = cv2.imencode(".jpg", img)
                    b64_image = base64.b64encode(buffer).decode("utf-8")
                    await ws.send(json.dumps({"type":"screenshot","data":b64_image}))
            
            elif action == "click":
                pyautogui.click()
            
            elif action == "move_mouse":
                x, y = data.get("x"), data.get("y")
                if x is not None and y is not None:
                    pyautogui.moveTo(x, y)
            
            elif action == "type":
                text = data.get("text","")
                pyautogui.typewrite(text)
        
        except Exception as e:
            print("Error handling message:", e)

# -----------------------------
# Server starten
# -----------------------------
async def main():
    print("Mischo Agent starting on port 8080...")
    async with websockets.serve(handler, "0.0.0.0", 8080, ssl=ssl_context):
        await asyncio.Future()  # Run forever

if __name__=="__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Mischo Agent stopped by user.")
