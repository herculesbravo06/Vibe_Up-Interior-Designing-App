const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
require('dotenv').config();

class ImageService {
  /**
   * Generate AI images using a cascading provider system:
   * 1. Stability AI (if key + credits available)
   * 2. Gemini Imagen (if Gemini key available) 
   * 3. Pollinations.ai (free — fast URL streaming)
   */
  async generate(prompt, aspect_ratio = "1:1", options = {}) {
    const style = options.style || 'modern';
    const enhancedPrompt = `${prompt}, ${style} style, luxury interior design, architectural concept, 8k, highly detailed`;

    // Provider 1: Stability AI
    if (process.env.STABILITY_API_KEY) {
      try {
        const result = await this.generateStability(enhancedPrompt, aspect_ratio);
        if (result && result.length > 0) return result;
      } catch (e) {
        console.warn("⚠️ Stability AI failed:", e.message);
      }
    }

    // Provider 2: Gemini Imagen
    if (process.env.GEMINI_API_KEY) {
      try {
        const result = await this.generateGeminiImage(enhancedPrompt);
        if (result && result.length > 0) return result;
      } catch (e) {
        console.warn("⚠️ Gemini Imagen failed:", e.message);
      }
    }

    // Provider 3: Pollinations.ai — instant URL streaming
    return this.generatePollinations(enhancedPrompt);
  }

  // ─── Stability AI ──────────────────────────────────────────
  async generateStability(prompt, aspect_ratio) {
    const formData = new FormData();
    formData.append('prompt', prompt);
    formData.append('output_format', 'webp');
    formData.append('aspect_ratio', aspect_ratio === "16:9" ? "16:9" : "1:1");

    const response = await axios.post(
      'https://api.stability.ai/v2beta/stable-image/generate/ultra',
      formData,
      {
        headers: {
          ...formData.getHeaders(),
          "Authorization": `Bearer ${process.env.STABILITY_API_KEY}`,
          "Accept": "image/*"
        },
        responseType: 'arraybuffer',
        timeout: 30000
      }
    );

    if (response.status === 200) {
      const filename = `ai_stability_${Date.now()}.webp`;
      const filepath = path.join(__dirname, '../public/ai_images', filename);
      this.ensureDir(path.dirname(filepath));
      fs.writeFileSync(filepath, response.data);

      const baseUrl = process.env.BASE_URL || 'http://localhost:5000';
      return [`${baseUrl}/ai_images/${filename}`];
    }
    return null;
  }

  // ─── Gemini Imagen ─────────────────────────────────────────
  async generateGeminiImage(prompt) {
    const { GoogleGenerativeAI } = require("@google/generative-ai");
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash", // Using standard flash for speed if 2.0 fails
    });

    const result = await model.generateContent(prompt);
    const response = result.response;
    // Note: Gemini text-to-image usually requires a specific model like Imagen 3.
    // If Imagen 3 isn't available on the API key, this might fail. 
    // We'll leave the placeholder logic here for when Imagen 3/Imagen 2 is enabled.
    return null;
  }

  // ─── Pollinations.ai — Modern Stable URL streaming ──────────
  async generatePollinations(prompt) {
    console.log("🎨 [Image Service] Generating via Pollinations.ai (Modern URL Stream)...");
    
    // As per error: enter.pollinations.ai used for modern anonymous-friendly requests
    // We'll use the /p/ path on pollinations.ai which is the most stable for embedding
    return [0, 1, 2].map(i => {
      const seed = Date.now() + i * 1543 + Math.floor(Math.random() * 88888);
      // Removed model=flux as it's often throttled on the anonymous endpoint
      return `https://pollinations.ai/p/${encodeURIComponent(prompt)}?width=1024&height=768&seed=${seed}&nologo=true`;
    });
  }

  // ─── Utility ───────────────────────────────────────────────
  ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
    }
  }
}

module.exports = new ImageService();
