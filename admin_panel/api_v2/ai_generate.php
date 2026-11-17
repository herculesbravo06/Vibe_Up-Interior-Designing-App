<?php
// ai_generate.php
// Connects to Google Gemini API (or other LLMs) for authentic AI Design Assistant responses.
header('Content-Type: application/json');

// ==========================================
// CONFIGURATION
// Replace 'YOUR_API_KEY_HERE' with a real API key (e.g. Gemini API key)
// or set the GEMINI_API_KEY environment variable.
// Get your key from: https://aistudio.google.com/app/apikey
// ==========================================
define('GEMINI_API_KEY', getenv('GEMINI_API_KEY') ?: 'YOUR_API_KEY_HERE');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    if ($data)
        $_POST = array_merge($_POST, $data);
}

$message = $_POST['message'] ?? '';
$context = $_POST['context'] ?? 'You are a professional Interior Design AI Assistant named VibeUp. Provide brief, actionable, and formatted (HTML) interior design advice.';

if (empty($message)) {
    echo json_encode(['status' => 'error', 'message' => 'No message provided']);
    exit;
}

if (GEMINI_API_KEY === 'YOUR_API_KEY_HERE') {
    // Fallback if API key is not configured
    echo json_encode([
        'status' => 'success',
        'response' => "<p><strong>Configure API Key:</strong> The AI backend is ready! Please edit <code>admin_panel/api_v2/ai_generate.php</code> and insert your actual Google Gemini API key to activate real responses.</p><p><em>You asked:</em> " . htmlspecialchars($message) . "</p>"
    ]);
    exit;
}

// Generate response using Google Gemini API
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" . GEMINI_API_KEY;

$payload = [
    "contents" => [
        [
            "parts" => [
                ["text" => $context . "\n\nUser Question: " . $message]
            ]
        ]
    ]
];

$ch = curl_init($url);
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($payload),
    CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_SSL_VERIFYPEER => false,
    CURLOPT_SSL_VERIFYHOST => 0,
    CURLOPT_CONNECTTIMEOUT => 10,
    CURLOPT_TIMEOUT => 30,
]);
$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpcode == 200 && $response) {
    $responseData = json_decode($response, true);
    if (isset($responseData['candidates'][0]['content']['parts'][0]['text'])) {
        $aiText = $responseData['candidates'][0]['content']['parts'][0]['text'];

        // Convert markdown to basic HTML for chat UI
        $aiText = preg_replace('/\*\*(.*?)\*\*/', '<strong>$1</strong>', $aiText);
        $aiText = preg_replace('/\*(.*?)\*/', '<em>$1</em>', $aiText);
        $aiText = nl2br($aiText);

        echo json_encode([
            'status' => 'success',
            'response' => $aiText
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid API response format']);
    }
} else {
    echo json_encode([
        'status' => 'error', 
        'message' => 'API connection failed', 
        'http_code' => $httpcode,
        'curl_error' => curl_error($ch),
        'api_response' => $response
    ]);
}
?>