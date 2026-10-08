#!/usr/bin/env python3
"""While the Umbriel overview is open, enter the 'ovl' submap so that typing
launches vicinae (see submap[ovl],* binds in ~/.config/umbriel/config.toml).
Leaves the submap when the overview closes."""
import json
import os
import socket
import time

SUBMAP = "ovl"


def sock_path():
    env = os.environ.get("UMBRIEL_SOCKET")
    if env:
        return env
    return f"/run/user/{os.getuid()}/umbriel-{os.environ.get('WAYLAND_DISPLAY', 'wayland-0')}.sock"


def main():
    sock = None
    buf = ""
    while True:
        try:
            if sock is None:
                sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                sock.settimeout(10)
                sock.connect(sock_path())
                sock.sendall((json.dumps({"cmd": "subscribe", "events": ["overview"]}) + "\n").encode())
                buf = ""
            while "\n" not in buf:
                chunk = sock.recv(4096)
                if not chunk:
                    raise ConnectionError("socket closed")
                buf += chunk.decode()
            line, _, buf = buf.partition("\n")
            ev = json.loads(line)
            if ev.get("event") == "overview":
                if ev["data"].get("open"):
                    sock.sendall((json.dumps({"cmd": "msg", "arg": f"submap:{SUBMAP}"}) + "\n").encode())
                else:
                    sock.sendall((json.dumps({"cmd": "msg", "arg": "submap:reset"}) + "\n").encode())
        except (socket.timeout, BlockingIOError):
            continue
        except (ConnectionError, OSError, json.JSONDecodeError, KeyError):
            if sock is not None:
                try:
                    sock.close()
                except OSError:
                    pass
                sock = None
            time.sleep(3)


if __name__ == "__main__":
    main()