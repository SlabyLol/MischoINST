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
import sys
import socket

try:
    from cryptography import x509
    from cryptography.x509.oid import NameOID
    from cryptography.hazmat.primitives import hashes, serialization
    from cryptography.hazmat.primitives.asymmetric import rsa
    from datetime import datetime, timedelta
except ImportError:
    print("Please install cryptography package: pip install cryptography")
    sys.exit(1)

CERT_FILE = "cert.pem"
KEY_FILE = "key.pem"

# Zertifikat erstellen, falls nicht vorhanden
if not os.path.exists(CERT_FILE) or not os.path.exists(KEY_FILE):
    print("Generating self-signed certificate in Python...")
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    with open(KEY_FILE, "wb") as f:
        f.write(key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption()
        ))
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, u"US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, u"State"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, u"City"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, u"Mischo"),
        x509.NameAttribute(NameOID.COMMON_NAME, u"localhost"),
    ])
    cert = x509.CertificateBuilder().subject_name(subject).issuer_name(issuer)\
        .public_key(key.public_key()).serial_number(x509.random_serial_number())\
        .not_valid_before(datetime.utcnow()).not_valid_after(datetime.utcnow()+timedelta(days=365))\
        .add_extension(x509.SubjectAlternativeName([x509.DNSName(u"localhost")]), critical=False)\
        .sign(key, hashes.SHA256())
    with open(CERT_FILE, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    print("Self-signed certificate generated successfully.")

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)

# -----------------------------
# IP-Erkennung
# -----------------------------
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Verbindung zu einem öffentlichen DNS, um lokale IP zu erkennen
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "YOUR-IP"
    finally:
        s.close()
    return ip

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
    ip = get_ip()
    print(f"Mischo Agent starting on port 8080...")
    print(f"Connect via WSS at: wss://{ip}:8080")
    async with websockets.serve(handler, "0.0.0.0", 8080, ssl=ssl_context):
        await asyncio.Future()  # Run forever

if __name__=="__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Mischo Agent stopped by user.")
