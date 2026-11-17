const Groq = require("groq-sdk");
require('dotenv').config();

class GroqService {
  constructor() {
    this.groq = new Groq({ apiKey: process.env.GROQ_API_KEY || "gsk_MOCK_KEY_FOR_ARCHITECTURE" });
  }

  async generate(messages, systemPrompt) {
    try {
      if (process.env.GROQ_API_KEY === "gsk_MOCK_KEY_FOR_ARCHITECTURE" || !process.env.GROQ_API_KEY) {
        return this.mockResponse(messages);
      }

      const completion = await this.groq.chat.completions.create({
        messages: [
          { role: "system", content: systemPrompt },
          ...messages
        ],
        model: "llama-3.3-70b-versatile",
        temperature: 0.7,
        max_tokens: 1024,
      });

      return completion.choices[0]?.message?.content || "";
    } catch (error) {
      console.error("Groq AI Error:", error.message);
      return this.mockResponse(messages);
    }
  }

  mockResponse(messages) {
    const lastMsg = messages[messages.length - 1].content.toLowerCase();
    if (lastMsg.includes('vastu')) {
      return "Based on premium Vastu Shastra principles, your room should be in the South-West corner for stability. (Mock Mode: Add GROQ_API_KEY to .env for real AI)";
    }
    return "This is a premium AI response from VibeUp. (Mock Mode: Add GROQ_API_KEY to .env for real AI)";
  }
}

module.exports = new GroqService();
