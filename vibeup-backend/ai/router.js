const groqService = require('./groqService');
const geminiService = require('./geminiService');
const imageService = require('./imageService');
const voiceService = require('./voiceService');
const vastuEngine = require('./vastuEngine');

class AiRouter {
  async process(input, userId, options = {}) {
    const { type, messages = [] } = options;
    const promptLower = input.toLowerCase();
    
    // 1. Determine Type if not forced
    let detectedType = type || "text";
    if (promptLower.includes("generate") || promptLower.includes("draw") || promptLower.includes("image") || promptLower.includes("design")) {
      detectedType = "image";
    }

    // 2. Vastu Intelligence Injection
    const vastuContext = vastuEngine.detectAndInject(input);
    const systemPrompt = `You are VibeUp's premium AI Assistant. You are an expert in Interior Design and Vastu Shastra.
      Current Vastu Knowledge Base Context (Inject these suggestions if relevant): 
      ${vastuContext}

      Always be polite, professional, and luxury-focused.
      If the user's question relates to furniture placement, always include Vastu directions.
      Format your responses with clear structure using numbered points or bullet points where appropriate.
      Use **bold** for key terms and important recommendations.
    `;

    // 3. Routing Logic: Hybrid Thinking
    let responseText = "";
    let data = null;
    let audioUrl = null;

    try {
      // Step A: Image Generation if requested
      if (detectedType === "image") {
        console.log(`🎨 [AI Router] Image generation requested by user ${userId}`);
        data = await imageService.generate(input, "16:9", options);
        console.log(`🎨 [AI Router] Image generation returned ${data ? data.length : 0} images`);
      }

      // Step B: Text Generation (Always includes Vastu context)
      const conversationalPrompt = detectedType === "image" 
        ? `The user requested an image: "${input}". Provide a 2-3 sentence explanation of the design choices made in the generated visuals, specifically highlighting Vastu compliance: ${vastuContext}`
        : systemPrompt;

      if (promptLower.length > 500 || promptLower.includes("analyze")) {
        console.log(`🧠 [AI Router] Using Gemini for deep analysis`);
        responseText = await geminiService.analyze(input);
      } else {
        console.log(`💬 [AI Router] Using Groq for conversational AI`);
        const groqMessages = messages.length > 0 ? messages : [{ role: "user", content: input }];
        responseText = await groqService.generate(groqMessages, conversationalPrompt);
      }

      // Step C: Voice synthesis if requested
      if (options.voiceOutput && responseText) {
        console.log(`🔊 [AI Router] Voice synthesis requested`);
        audioUrl = await voiceService.synthesize(responseText);
        if (audioUrl) {
          console.log(`🔊 [AI Router] Voice generated: ${audioUrl}`);
        }
      }

      return { 
        status: "success", 
        type: detectedType, 
        response: responseText, 
        data: data, 
        audioUrl, 
        vastuApplied: vastuContext.length > 0 
      };

    } catch (e) {
      console.error("AI Router Error:", e);
      return { status: "error", message: "AI Assistant is currently unavailable. " + e.message };
    }
  }
}

module.exports = new AiRouter();
