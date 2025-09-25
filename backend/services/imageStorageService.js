const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const IMAGE_STORAGE_PATH = path.join(__dirname, '..', 'uploads', 'plant_images');

if (!fs.existsSync(IMAGE_STORAGE_PATH)) {
  fs.mkdirSync(IMAGE_STORAGE_PATH, { recursive: true });
}

async function saveImage(base64Image) {
  try {
    // Extract image extension and data
    const matches = base64Image.match(/^data:(image\/\w+);base64,(.+)$/);
    if (!matches) {
      throw new Error('Invalid base64 image format');
    }
    const ext = matches[1].split('/')[1];
    const data = matches[2];
    const buffer = Buffer.from(data, 'base64');

    // Generate unique filename
    const filename = `${uuidv4()}.${ext}`;
    const filepath = path.join(IMAGE_STORAGE_PATH, filename);

    // Save file
    await fs.promises.writeFile(filepath, buffer);

    // Return relative path or URL
    return `/uploads/plant_images/${filename}`;
  } catch (error) {
    throw new Error(`Failed to save image: ${error.message}`);
  }
}

module.exports = {
  saveImage
};
