# PipeWire RAOP vs Sonos: session killed by RTSP SETUP 500

Upstream bug report material (draft).

## Summary

Streaming to Sonos speakers (AirPlay 2 devices) via PipeWire's
`libpipewire-module-raop-discover` establishes the RTSP session
(OPTIONS/AUTH-SETUP/ANNOUNCE all 200 OK) but the device answers the
**SETUP with HTTP 500** ~20 seconds into the session, every time; the
sink then tears itself down. No audio is ever heard.

## Environment

- Fedora 44, PipeWire 1.6.9 (pipewire / pipewire-pulse)
- Sonos One SL (firmware `p20.97.1-80312`) and Sonos Ray (same firmware)
- Both advertise: `et=0,4` (none + auth_setup), `cn=0,1` (PCM + ALAC),
  `tp=UDP`, `da=true`
- Same setup streams successfully to a MacBook (macOS AirPlay receiver,
  `et=0,3,5`) — session survives indefinitely there

## Config

```toml
# ~/.config/pipewire/pipewire.conf.d/50-raop.conf
context.modules = [
    { name = libpipewire-module-raop-discover
        args = { raop.latency.ms = 255.42 }
    }
]
```

(`raop.latency.ms = 255.42` = 32 × 352-sample packets @44.1 kHz; the
default 250 ms logs `sess.latency.msec 250.000000 should be an integer
multiple of rtp.ptime 7.981859`.)

## Observed log sequence (PIPEWIRE_DEBUG=3)

```
mod.raop-sink: connected
mod.raop-sink: options status: 200
mod.raop-sink: auth-setup status: 200
mod.raop-sink: announce status: 200
   Transport: RTP/AVP/UDP;unicast;interleaved=0-1;mode=record;control_port=6001;timing_port=6002
   ... ~20 s later ...
mod.raop-sink: setup status: 500
pw.node: (raop_sink...-) running -> suspended
pw.node: (raop_sink...-) destroy
mod.raop-sink: disconnected
```

The SETUP 500 occurs ~20 s after ANNOUNCE regardless of whether the
client is still streaming (tried 8 s, 15 s, 60 s, 90 s tones) and
regardless of `raop.audio.codec` (`PCM`, `ALAC`) or
`raop.encryption.type` (`none`, `auth_setup`) forcing.

## Expected

A 200 on SETUP (or clear error before ANNOUNCE) and audible audio; the
device explicitly offers both codecs and unauthenticated+MFiSAP modes.

## Notes / likely angle

- Sonos firmware is current; the same speakers accept sessions from
  iOS/macOS devices.
- The `Transport:` parameters in the ANNOUNCE reply
  (`control_port=6001;timing_port=6002`) may hint the device expects the
  audio/timing RTP streams on specific ports; the late SETUP (sent ~20 s
  in, only after the client stream has been running) may be rejected
  because the device already considers the session live.

## Bonus finding: raop latency config is inert on 1.6.9

- `raop.latency.ms` is parsed with `spa_atou32` (integer only): float
  values (e.g. `255.42`) are silently dropped and the session stays at
  `RAOP_LATENCY_MS` (250).
- Even with an integer value (575) and a sample-exact per-stream
  `node.latency = "25344/44100"` (352×72 samples), the RTP stream still
  reports `sess.latency.msec 250` and warns against `rtp.ptime
  7.981859` — the property never reaches the stream's session latency
  in this release. Config-level latency alignment is therefore not
  possible on 1.6.9; the SETUP 500 occurs identically regardless.

## Resolution (2026-10-11)

Working alternative found: [LuisEGR/sonos-linux](https://github.com/LuisEGR/sonos-linux)
- streams system audio to Sonos via its native UPnP/SOAP protocol
  (SSDP discovery -> SetAVTransportURI -> Play), completely bypassing
  AirPlay/RAOP. Verified working on the same Sonos One SL + Ray that
  reject PipeWire's SETUP. 2-5 s latency, fine for music.
- Live setup: `~/.local/bin/sonos-linux` + tray.py, user service
  `sonos-linux.service` (pulled by graphical-session.target). Dependencies:
  ffmpeg (libmp3lame), pactl, pw-cli, gtk3/python3-gobject for the tray.
- Requires the Wi-Fi interface in firewalld's `trusted` zone (SSDP
  multicast + the random-port HTTP stream server need inbound access).