#!/usr/bin/env python3
"""
Generates GoMeet brand placeholder icons for the PWA manifest.

Produces four PNG files in web/icons/ using the GoMeet brand palette:
  Background: #0F0F1A (dark navy)
  Brand accent: #FF4458 (rose-coral)

Standard icons (no padding): Icon-192.png, Icon-512.png
Maskable icons (~10% safe-zone padding): Icon-maskable-192.png, Icon-maskable-512.png

Run with: python tool/generate_icons.py
"""

import os
from PIL import Image, ImageDraw


def generate_icon(path, size, safe_padding=0):
    """Creates a single square PNG icon.

    Args:
        path: Output file path.
        size: Canvas size in pixels (width == height).
        safe_padding: Pixels of safe-zone to leave clear on each edge (maskable icons).
    """
    # Create a new image with brand background #0F0F1A
    img = Image.new('RGB', (size, size), color=(0x0F, 0x0F, 0x1A))
    draw = ImageDraw.Draw(img)

    center_x = size // 2
    center_y = size // 2

    # Outer brand circle — #FF4458 (rose-coral)
    outer_radius = center_x - safe_padding
    draw.ellipse(
        [center_x - outer_radius, center_y - outer_radius,
         center_x + outer_radius, center_y + outer_radius],
        fill=(0xFF, 0x44, 0x58)
    )

    # Inner white circle (represents the GoMeet "G" / logo nucleus)
    # Size: 45% of outer radius keeps proportions clean at all sizes
    inner_radius = int(outer_radius * 0.45)
    draw.ellipse(
        [center_x - inner_radius, center_y - inner_radius,
         center_x + inner_radius, center_y + inner_radius],
        fill=(0xFF, 0xFF, 0xFF)
    )

    # Small navy circle at centre (creates a ring effect that mimics the logo mark)
    dot_radius = int(outer_radius * 0.18)
    draw.ellipse(
        [center_x - dot_radius, center_y - dot_radius,
         center_x + dot_radius, center_y + dot_radius],
        fill=(0x0F, 0x0F, 0x1A)
    )

    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # Save the image as PNG
    img.save(path, 'PNG')
    print(f'  Created: {path}  ({size}x{size}, padding={safe_padding})')


def main():
    """Generate all GoMeet PWA icons."""
    print('=== Generating GoMeet PWA Icons ===')

    # Standard icons — no safe-zone padding, icon fills the full canvas
    generate_icon('web/icons/Icon-192.png', 192, safe_padding=0)
    generate_icon('web/icons/Icon-512.png', 512, safe_padding=0)

    # Maskable icons — ~10% safe-zone padding on all sides
    # 10% of 192 = 19.2  → 19 px
    # 10% of 512 = 51.2  → 51 px
    generate_icon('web/icons/Icon-maskable-192.png', 192, safe_padding=19)
    generate_icon('web/icons/Icon-maskable-512.png', 512, safe_padding=51)

    print('✓ All icons generated in web/icons/')


if __name__ == '__main__':
    main()
