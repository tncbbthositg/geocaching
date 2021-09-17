import { Command } from 'commander';
import { promises as fs } from 'fs';
import Jimp from 'jimp';
import path from 'path';

type FileHandle = fs.FileHandle;

function getBrightness(color: number) {
  const { r, g, b } = Jimp.intToRGBA(color);
  const hsp = Math.sqrt(
    0.299 * r * r +
    0.587 * g * g +
    0.114 * b * b
  );

  return hsp;
}

export function isDark(color: number) {
  const brightness = getBrightness(color);
  return brightness < 127.5;
}

async function writeHeader(width: number, height: number, fileHandle: FileHandle) {
  await fileHandle.write('<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n');
  await fileHandle.write('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n');
  await fileHandle.write(`<svg width="100%" height="100%" viewBox="0 0 ${width} ${height}" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n`);
}

async function writeFooter(fileHandle: FileHandle) {
  await fileHandle.write(`</svg>`);
}

async function writeBlock(x: number, y: number, fileHandle: FileHandle) {
  await fileHandle.write(`  <rect x="${x}" y="${y}" width=".999999" height=".999999"/>\n`);
}

async function runProgram(filename: string) {
  console.log("Parsing:", filename);
  const image = await Jimp.read(filename);

  const imageWidth = image.getWidth();
  const imageHeight = image.getHeight();

  console.log("Encoding QR code size", imageWidth, 'x', imageHeight);

  const { dir, name } = path.parse(filename);
  const outputFileName = path.join(dir, `${name}.svg`);

  console.log("Writing svg file", outputFileName);
  const file = await fs.open(outputFileName, 'w');
  try {
    await writeHeader(imageWidth, imageHeight, file);

    for (var y = 0; y < imageHeight; ++y) {
      for (var x = 0; x < imageWidth; ++x) {
        const pixelColor = image.getPixelColor(x, y);
        if (isDark(pixelColor)) {
          await writeBlock(x, y, file);
        }
      }

      file.write('\n');
    }

    await writeFooter(file);
    console.log("Finished building SVG for openSCAD", outputFileName);
  } finally {
    await file.close();
  }
}

const program = new Command();
program
  .arguments('<filename>')
  .action(runProgram)
  .parseAsync(process.argv);
