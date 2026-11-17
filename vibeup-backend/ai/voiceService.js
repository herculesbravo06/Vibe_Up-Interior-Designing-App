const axios = require('axios');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

class VoiceService {
  constructor() {
    this.apiKey = process.env.ELEVENLABS_API_KEY;
    this.voiceId = process.env.ELEVENLABS_VOICE_ID || 'pNInz6obpgmqS2iF5SsH';
  }

  async synthesize(text) {
    if (!this.apiKey) return null;
    
    try {
      const response = await axios.post(
        `https://api.elevenlabs.io/v1/text-to-speech/${this.voiceId}`,
        { text, model_id: "eleven_monolingual_v1", voice_settings: { stability: 0.5, similarity_boost: 0.5 } },
        { headers: { "xi-api-key": this.apiKey, "Accept": "audio/mpeg" }, responseType: 'arraybuffer' }
      );
      
      const filename = `voice_${Date.now()}.mp3`;
      const filepath = path.join(__dirname, '../public/ai_voice', filename);
      
      // Ensure directory exists
      const dir = path.dirname(filepath);
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
      
      fs.writeFileSync(filepath, Buffer.from(response.data));
      
      const baseUrl = process.env.BASE_URL || 'http://localhost:5000';
      return `${baseUrl}/ai_voice/${filename}`;
    } catch (e) {
      console.error("ElevenLabs Error:", e.response?.data?.toString() || e.message);
      return null;
    }
  }
}

module.exports = new VoiceService();
