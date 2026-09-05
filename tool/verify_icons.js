#!/usr/bin/env node
/**
 * Verifies that PWA icon files exist and have correct dimensions.
 * This is a replacement for the Flutter test that checks icon dimensions.
 */

const fs = require('fs');
const path = require('path');

// PNG dimension extractor
function getPNGDimensions(filePath) {
  const buffer = fs.readFileSync(filePath);

  // Check PNG signature
  if (!buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) {
    throw new Error('Invalid PNG signature');
  }

  // IHDR chunk starts at offset 8
  // Width is at offset 16 (4 bytes, big-endian)
  // Height is at offset 20 (4 bytes, big-endian)
  const width = buffer.readUInt32BE(16);
  const height = buffer.readUInt32BE(20);

  return { width, height };
}

const iconSpecs = [
  { path: 'web/icons/Icon-192.png', size: 192 },
  { path: 'web/icons/Icon-512.png', size: 512 },
  { path: 'web/icons/Icon-maskable-192.png', size: 192 },
  { path: 'web/icons/Icon-maskable-512.png', size: 512 },
];

console.log('=== PWA Icons — Verification ===\n');

let passed = 0;
let failed = 0;

for (const spec of iconSpecs) {
  const filePath = spec.path;
  const expectedSize = spec.size;

  // Test 1: File exists
  if (!fs.existsSync(filePath)) {
    console.log(`❌ FAIL: ${filePath} does not exist`);
    failed++;
    continue;
  }
  console.log(`✓ PASS: ${filePath} exists`);
  passed++;

  // Test 2: Valid PNG with correct dimensions
  try {
    const dims = getPNGDimensions(filePath);
    if (dims.width === expectedSize && dims.height === expectedSize) {
      console.log(`✓ PASS: ${filePath} is ${dims.width}x${dims.height} PNG`);
      passed++;
    } else {
      console.log(`❌ FAIL: ${filePath} has wrong dimensions: ${dims.width}x${dims.height} (expected ${expectedSize}x${expectedSize})`);
      failed++;
    }
  } catch (err) {
    console.log(`❌ FAIL: ${filePath} is not a valid PNG: ${err.message}`);
    failed++;
  }
}

console.log(`\n=== Summary ===`);
console.log(`Passed: ${passed}`);
console.log(`Failed: ${failed}`);

if (failed === 0) {
  console.log('\n✓ All icon tests passed!');
  process.exit(0);
} else {
  console.log('\n❌ Some tests failed');
  process.exit(1);
}
