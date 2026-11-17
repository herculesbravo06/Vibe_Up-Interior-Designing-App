const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

class GeminiService {
  constructor() {
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "GEMINI_MOCK_KEY");
  }

  async analyze(prompt, imagePath = null) {
    if (!process.env.GEMINI_API_KEY || process.env.GEMINI_API_KEY === "GEMINI_MOCK_KEY") {
      console.log("⚠️ Gemini running in MOCK mode — add GEMINI_API_KEY to .env");
      return this.mockAnalysis(prompt);
    }

    try {
      const model = this.genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
      const result = await model.generateContent([prompt]);
      console.log("✅ Gemini analysis completed with real API");
      return result.response.text();
    } catch (error) {
      console.error("Gemini API Error:", error.message);
      // Fallback to mock if API fails
      return this.mockAnalysis(prompt);
    }
  }

  mockAnalysis(prompt) {
    return "I've analyzed your design concept. The layout is structurally sound and follows premium aesthetic patterns. (Mock Mode: Add GEMINI_API_KEY to .env)";
  }
}

module.exports = new GeminiService();
