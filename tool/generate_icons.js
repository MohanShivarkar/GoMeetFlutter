#!/usr/bin/env node
/**
 * Generates GoMeet brand placeholder icons for the PWA manifest.
 *
 * Produces four PNG files in web/icons/ using the GoMeet brand palette:
 *   Background: #0F0F1A (dark navy)
 *   Brand accent: #FF4458 (rose-coral)
 *
 * Standard icons (no padding): Icon-192.png, Icon-512.png
 * Maskable icons (~10% safe-zone padding): Icon-maskable-192.png, Icon-maskable-512.png
 *
 * Run with: node tool/generate_icons.js
 */

const fs = require('fs');
const path = require('path');

/**
 * Creates a simple PNG file with the GoMeet brand icon design.
 * Uses raw PNG generation with minimal dependencies.
 */

// PNG magic number and basic structure
function createPNG(width, height, pixels) {
  // PNG signature
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  // Helper to create PNG chunks
  function createChunk(type, data) {
    const typeBuffer = Buffer.from(type);
    const crcData = Buffer.concat([typeBuffer, data]);

    const crc32 = (buf) => {
      let crc = 0xFFFFFFFF;
      for (let i = 0; i < buf.length; i++) {
        const byte = buf[i];
        crc = crc ^ byte;
        for (let j = 0; j < 8; j++) {
          crc = (crc >>> 1) ^ ((crc & 1) ? 0xEDB88320 : 0);
        }
      }
      return (crc ^ 0xFFFFFFFF) >>> 0;
    };

    const lengthBuffer = Buffer.alloc(4);
    lengthBuffer.writeUInt32BE(data.length);

    const crcBuffer = Buffer.alloc(4);
    crcBuffer.writeUInt32BE(crc32(crcData));

    return Buffer.concat([lengthBuffer, typeBuffer, data, crcBuffer]);
  }

  // IHDR chunk (image header)
  const ihdrData = Buffer.alloc(13);
  ihdrData.writeUInt32BE(width, 0);
  ihdrData.writeUInt32BE(height, 4);
  ihdrData[8] = 8;   // bit depth
  ihdrData[9] = 2;   // color type (RGB)
  ihdrData[10] = 0;  // compression
  ihdrData[11] = 0;  // filter
  ihdrData[12] = 0;  // interlace

  // IDAT chunk (image data) - simplified for dev use
  // Note: This is a simplified raw pixel buffer approach
  const pixelData = Buffer.alloc(height * (width * 3 + 1));
  let offset = 0;

  for (let y = 0; y < height; y++) {
    pixelData[offset++] = 0; // filter type
    for (let x = 0; x < width; x++) {
      const idx = (y * width + x) * 3;
      pixelData[offset++] = pixels[idx];
      pixelData[offset++] = pixels[idx + 1];
      pixelData[offset++] = pixels[idx + 2];
    }
  }

  // Zlib compression (simplified - just deflate without compression for now)
  const zlib = require('zlib');
  const compressed = zlib.deflateSync(pixelData);

  // IEND chunk (end)
  const iendData = Buffer.alloc(0);

  return Buffer.concat([
    signature,
    createChunk('IHDR', ihdrData),
    createChunk('IDAT', compressed),
    createChunk('IEND', iendData),
  ]);
}

// Generate pixels for the icon
function generateIconPixels(size, safePadding) {
  const pixels = Buffer.alloc(size * size * 3);

  // Fill with background color #0F0F1A
  const bgR = 0x0F, bgG = 0x0F, bgB = 0x1A;
  const brandR = 0xFF, brandG = 0x44, brandB = 0x58;
  const whiteR = 0xFF, whiteG = 0xFF, whiteB = 0xFF;

  const center = size / 2;
  const outerRadius = center - safePadding;

  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const idx = (y * size + x) * 3;

      // Distance from center
      const dx = x - center;
      const dy = y - center;
      const dist = Math.sqrt(dx * dx + dy * dy);

      let r = bgR, g = bgG, b = bgB;

      // Outer brand circle
      if (dist <= outerRadius) {
        r = brandR;
        g = brandG;
        b = brandB;
      }

      // Inner white circle (45% of outer radius)
      const innerRadius = outerRadius * 0.45;
      if (dist <= innerRadius) {
        r = whiteR;
        g = whiteG;
        b = whiteB;
      }

      // Small navy dot (18% of outer radius)
      const dotRadius = outerRadius * 0.18;
      if (dist <= dotRadius) {
        r = bgR;
        g = bgG;
        b = bgB;
      }

      pixels[idx] = r;
      pixels[idx + 1] = g;
      pixels[idx + 2] = b;
    }
  }

  return pixels;
}

function generateIcon(filePath, size, safePadding) {
  const pixels = generateIconPixels(size, safePadding);
  const pngBuffer = createPNG(size, size, pixels);

  // Ensure directory exists
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(filePath, pngBuffer);
  console.log(`  Created: ${filePath}  (${size}x${size}, padding=${safePadding})`);
}

// Main
console.log('=== Generating GoMeet PWA Icons ===');

// Standard icons
generateIcon('web/icons/Icon-192.png', 192, 0);
generateIcon('web/icons/Icon-512.png', 512, 0);

// Maskable icons with safe-zone padding
generateIcon('web/icons/Icon-maskable-192.png', 192, 19);
generateIcon('web/icons/Icon-maskable-512.png', 512, 51);

console.log('✓ All icons generated in web/icons/');
