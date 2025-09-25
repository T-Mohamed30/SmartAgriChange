const axios = require('axios');

const AI_API_URL = process.env.AI_API_URL || 'http://localhost:8000/api/plant-analysis';

async function analyzePlantImage(base64Image) {
  try {
    const response = await axios.post(AI_API_URL, {
      image: base64Image
    }, {
      timeout: 10000 // 10 seconds timeout
    });

    if (response.status !== 200) {
      throw new Error(`AI service responded with status ${response.status}`);
    }

    return response.data;
  } catch (error) {
    throw new Error(`AI service error: ${error.message}`);
  }
}

module.exports = {
  analyzePlantImage
};
