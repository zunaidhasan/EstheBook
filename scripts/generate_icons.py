#!/usr/bin/env python3
"""Generate placeholder brand icons for EstheBook as valid PNGs (stdlib only).

Draws a blush rounded square with a white disc and a gold heart, which matches
the app's design tokens. Replace with final artwork when available, e.g. via
the `flutter_launcher_icons` package.
"""
import math
import os
import struct
import zlib

OUT_ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "web")

BLUSH_TOP = (247, 232, 234)    # #F7E8EA
BLUSH_BOTTOM = (232, 196, 203) # #E8C4CB
WHITE = (255, 255, 255)
GOLD = (201, 169, 106)         # #C9A96A
GOLD_EDGE = (176, 141, 78)


def _clamp(v: float) -> int:
    return max(0, min(255, int(round(v))))


def _rounded_rect_alpha(px: float, py: float, size: float, radius: float) -> int:
    """255 inside the rounded rect, 0 outside, with a 1px soft edge."""
    r = radius
    cx = min(max(px, r), size - r)
    cy = min(max(py, r), size - r)
    dx, dy = px - cx, py - cy
    d = math.hypot(dx, dy)
    # Distance outside the rounded shape (positive = outside).
    outside = d - r if (dx != 0 or dy != 0) else max(px - (size - r), r - px, py - (size - r), r - py) - r + 0.0
    outside = max(outside, 0.0)
    if outside <= 0:
        return 255
    if outside >= 1.0:
        return 0
    return _clamp(255 * (1.0 - outside))


def _heart_inside(hx: float, hy: float) -> float:
    """Implicit heart curve. f < 0 means inside."""
    return (hx * hx + hy * hy - 1.0) ** 3 - hx * hx * hy ** 3


def make_pixels(size: int, maskable: bool):
    content_scale = 1.0 if not maskable else 0.72
    offset = 0.0 if not maskable else size * (1.0 - content_scale) / 2.0
    radius = 0.0 if maskable else size * 0.22

    cx = size / 2.0
    cy = size / 2.0
    disc_r = size * 0.30 * content_scale + (0.0 if maskable else 0.0)
    heart_scale = size * 0.155 * content_scale

    rows = []
    for y in range(size):
        row = bytearray()
        row.append(0)  # PNG filter type: None
        for x in range(size):
            fy = y + 0.5
            fx = x + 0.5

            alpha = 255 if maskable else _rounded_rect_alpha(fx, fy, size, radius)

            # Background: soft vertical gradient blush.
            t = fy / max(size - 1, 1)
            r = BLUSH_TOP[0] + (BLUSH_BOTTOM[0] - BLUSH_TOP[0]) * t
            g = BLUSH_TOP[1] + (BLUSH_BOTTOM[1] - BLUSH_TOP[1]) * t
            b = BLUSH_TOP[2] + (BLUSH_BOTTOM[2] - BLUSH_TOP[2]) * t

            # White disc behind the heart.
            dx, dy = fx - cx, fy - cy
            dist = math.hypot(dx, dy)
            if maskable:
                ux, uy = fx - offset - size * content_scale / 2, fy - offset - size * content_scale / 2
                dist = math.hypot(ux, uy) / content_scale
                dx, dy = ux / content_scale, uy / content_scale

            edge = max(1.2, size / 128.0)
            if dist <= disc_r + edge:
                blend = min(1.0, max(0.0, (disc_r + edge - dist) / (2 * edge)))
                r = r + (WHITE[0] - r) * blend
                g = g + (WHITE[1] - g) * blend
                b = b + (WHITE[2] - b) * blend

            # Gold heart.
            hs = (fx - cx) / heart_scale
            hy_ = -(fy - cy * 1.04) / heart_scale
            f = _heart_inside(hs, hy_ + 0.12)
            if f < 0.05:
                col = GOLD if f < -0.05 else GOLD_EDGE
                fr = min(1.0, max(0.0, (0.05 - f) / 0.10))
                r = r + (col[0] - r) * fr
                g = g + (col[1] - g) * fr
                b = b + (col[2] - b) * fr

            row += bytes((_clamp(r), _clamp(g), _clamp(b), alpha))
        rows.append(bytes(row))
    return b"".join(rows)


def write_png(path: str, size: int, maskable: bool = False) -> None:
    raw = make_pixels(size, maskable)

    def chunk(ctype: bytes, data: bytes) -> bytes:
        return (struct.pack(">I", len(data)) + ctype + data
                + struct.pack(">I", zlib.crc32(ctype + data) & 0xFFFFFFFF))

    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", ihdr)
           + chunk(b"IDAT", zlib.compress(raw, 9))
           + chunk(b"IEND", b""))

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as fh:
        fh.write(png)
    print(f"wrote {path} ({len(png)} bytes)")


def main() -> None:
    write_png(os.path.join(OUT_ROOT, "favicon.png"), 16)
    write_png(os.path.join(OUT_ROOT, "icons", "Icon-192.png"), 192)
    write_png(os.path.join(OUT_ROOT, "icons", "Icon-512.png"), 512)
    write_png(os.path.join(OUT_ROOT, "icons", "Icon-maskable-192.png"), 192, maskable=True)
    write_png(os.path.join(OUT_ROOT, "icons", "Icon-maskable-512.png"), 512, maskable=True)


if __name__ == "__main__":
    main()
