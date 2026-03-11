#!/usr/bin/env python3
"""Upload files to Flipper Zero SD card via serial CLI."""

import serial
import sys
import os
import time
import glob

FLIPPER_PORT = None
BAUD = 230400
SD_TARGET = "/ext/apps_data/marauder"

def find_flipper():
    ports = glob.glob("/dev/cu.usbmodemflip_*")
    if ports:
        return ports[0]
    return None

def send_cmd(ser, cmd, wait=0.5):
    ser.write(b"\r\n")
    time.sleep(0.1)
    ser.read(ser.in_waiting)
    ser.write(f"{cmd}\r\n".encode())
    time.sleep(wait)
    resp = ser.read(ser.in_waiting).decode(errors="replace")
    return resp

def upload_file(ser, local_path, remote_path):
    with open(local_path, "rb") as f:
        data = f.read()
    
    size = len(data)
    filename = os.path.basename(local_path)
    
    ser.read(ser.in_waiting)
    ser.write(f"storage write_chunk {remote_path} {size}\r\n".encode())
    time.sleep(0.3)
    
    resp = ser.read(ser.in_waiting).decode(errors="replace")
    
    if "Ready" not in resp and "ready" not in resp:
        ser.read(ser.in_waiting)
        ser.write(f"storage remove {remote_path}\r\n".encode())
        time.sleep(0.3)
        ser.read(ser.in_waiting)
        
        ser.write(f"storage write_chunk {remote_path} {size}\r\n".encode())
        time.sleep(0.3)
        resp = ser.read(ser.in_waiting).decode(errors="replace")
    
    chunk_size = 512
    sent = 0
    while sent < size:
        chunk = data[sent:sent + chunk_size]
        ser.write(chunk)
        sent += len(chunk)
        time.sleep(0.01)
    
    time.sleep(0.5)
    resp = ser.read(ser.in_waiting).decode(errors="replace")
    return "OK" in resp or sent == size

def upload_simple(ser, local_path, remote_path):
    """Fallback: write file line by line using storage write."""
    with open(local_path, "r") as f:
        content = f.read()

    send_cmd(ser, f"storage remove {remote_path}", 0.3)
    
    lines = content.split("\n")
    first = True
    for line in lines:
        safe_line = line.replace('"', '\\"')
        if first:
            send_cmd(ser, f'storage write {remote_path} "{safe_line}"', 0.1)
            first = False
        else:
            send_cmd(ser, f'storage write {remote_path} "\n{safe_line}"', 0.1)
    
    return True

def main():
    port = find_flipper()
    if not port:
        print("No Flipper Zero found! Make sure it's connected via USB.")
        print("Looking for /dev/cu.usbmodemflip_*")
        sys.exit(1)
    
    print(f"Found Flipper at: {port}")
    
    portals_dir = os.path.join(os.path.dirname(__file__), "portals")
    staging_dir = os.path.join(os.path.dirname(__file__), "staging")
    
    if len(sys.argv) > 1 and sys.argv[1] == "--staged":
        files_to_upload = []
        if os.path.exists(os.path.join(staging_dir, "index.html")):
            files_to_upload.append((os.path.join(staging_dir, "index.html"), f"{SD_TARGET}/index.html"))
        if os.path.exists(os.path.join(staging_dir, "ap.config.txt")):
            files_to_upload.append((os.path.join(staging_dir, "ap.config.txt"), f"{SD_TARGET}/ap.config.txt"))
    elif len(sys.argv) > 1 and sys.argv[1] == "--all":
        files_to_upload = []
        for root, dirs, files in os.walk(portals_dir):
            for f in files:
                if f.endswith(".html"):
                    local = os.path.join(root, f)
                    rel = os.path.relpath(local, portals_dir)
                    clean = rel.replace(os.sep, "_")
                    files_to_upload.append((local, f"{SD_TARGET}/{clean}"))
    elif len(sys.argv) > 1:
        local_file = sys.argv[1]
        if not os.path.exists(local_file):
            local_file = os.path.join(portals_dir, sys.argv[1])
        if not os.path.exists(local_file):
            print(f"File not found: {sys.argv[1]}")
            sys.exit(1)
        remote_name = os.path.basename(local_file)
        files_to_upload = [(local_file, f"{SD_TARGET}/{remote_name}")]
    else:
        print("Usage:")
        print("  python3 flipper-upload.py --staged    Upload staged index.html + ap.config.txt")
        print("  python3 flipper-upload.py --all       Upload ALL portals")
        print("  python3 flipper-upload.py <file>      Upload a specific file")
        sys.exit(0)
    
    try:
        ser = serial.Serial(port, BAUD, timeout=2)
        time.sleep(1)
        ser.read(ser.in_waiting)
    except Exception as e:
        print(f"Could not connect to Flipper: {e}")
        print("Make sure no other app (qFlipper, screen) is using the serial port.")
        sys.exit(1)
    
    print(f"Connected to Flipper Zero!")
    
    resp = send_cmd(ser, f"storage mkdir {SD_TARGET}", 0.5)
    print(f"Target directory: {SD_TARGET}")
    
    total = len(files_to_upload)
    success = 0
    
    for i, (local, remote) in enumerate(files_to_upload, 1):
        name = os.path.basename(local)
        size = os.path.getsize(local)
        print(f"  [{i}/{total}] Uploading {name} ({size}B)...", end=" ", flush=True)
        
        try:
            ok = upload_file(ser, local, remote)
            if ok:
                print("OK")
                success += 1
            else:
                print("WARN (trying fallback)...", end=" ", flush=True)
                ok = upload_simple(ser, local, remote)
                if ok:
                    print("OK")
                    success += 1
                else:
                    print("FAILED")
        except Exception as e:
            print(f"ERROR: {e}")
    
    ser.close()
    print(f"\nDone! {success}/{total} files uploaded to Flipper.")
    
    if success > 0:
        print(f"\nOn your Flipper:")
        print(f"  1. Open Apps > GPIO > ESP32 WiFi Marauder")
        print(f"  2. Run: evilportal -c start")
        print(f"  3. Stop: stopscan")

if __name__ == "__main__":
    main()
