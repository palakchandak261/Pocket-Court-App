const https = require('https');

const SYSTEM_PROMPT =
  'You are an expert Indian legal assistant inside the "Pocket Court" app. ' +
  'Your role is to help Indian citizens understand their legal rights in simple, clear language. ' +
  'Always refer to specific Indian laws: IPC, CrPC, Motor Vehicles Act, Consumer Protection Act, IT Act, Constitution of India, etc. ' +
  'Mention relevant sections and articles when applicable. ' +
  'Suggest practical next steps (file FIR, approach consumer forum, call helpline etc.). ' +
  'Include relevant helpline numbers when appropriate (100 police, 181 women, 1930 cyber, 1800-11-4000 consumer). ' +
  'Keep responses concise and easy to understand for a common citizen. ' +
  'Always add a disclaimer that this is general legal awareness, not professional legal advice. ' +
  'If asked about non-legal topics, politely redirect to legal matters. ' +
  'Respond in the same language the user writes in (Hindi or English).';

const chat = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message || typeof message !== 'string' || message.trim().length === 0)
      return res.status(400).json({ success: false, message: 'message is required' });
    if (message.length > 1000)
      return res.status(400).json({ success: false, message: 'Message too long (max 1000 chars)' });

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.json({ success: true, data: _fallback(message) });
    }

    const payload = JSON.stringify({
      contents: [{ parts: [{ text: `${SYSTEM_PROMPT}\n\nUser: ${message.trim()}` }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 800 },
    });

    const geminiRes = await _postGemini(apiKey, payload);
    const reply = geminiRes?.candidates?.[0]?.content?.parts?.[0]?.text;

    res.json({ success: true, data: reply || _fallback(message) });
  } catch (e) {
    console.error('[AI] Error:', e.message);
    res.json({ success: true, data: _fallback(req.body?.message || '') });
  }
};

// ── Gemini HTTP call (no extra dependency) ────────────────────────────────────
function _postGemini(apiKey, payload) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) },
    };
    const req = https.request(options, (r) => {
      let data = '';
      r.on('data', (chunk) => (data += chunk));
      r.on('end', () => {
        try { resolve(JSON.parse(data)); } catch { reject(new Error('Invalid JSON from Gemini')); }
      });
    });
    req.on('error', reject);
    req.setTimeout(15000, () => { req.destroy(); reject(new Error('Gemini timeout')); });
    req.write(payload);
    req.end();
  });
}

// ── Offline fallback responses ────────────────────────────────────────────────
function _fallback(msg) {
  const m = msg.toLowerCase();
  if (m.includes('fir') || m.includes('police'))
    return 'To file an FIR, visit your nearest police station. If refused, approach the SP or file online at your state police portal. Helpline: 100';
  if (m.includes('consumer') || m.includes('refund'))
    return 'Under Consumer Protection Act 2019, you can file a complaint at consumerhelpline.gov.in or call 1800-11-4000.';
  if (m.includes('cyber') || m.includes('fraud') || m.includes('upi'))
    return 'Report cyber crime at cybercrime.gov.in or call 1930 immediately. Preserve all evidence.';
  if (m.includes('traffic') || m.includes('challan'))
    return 'Pay e-challans at echallan.parivahan.gov.in. Contest wrong challans in court.';
  if (m.includes('domestic') || m.includes('violence'))
    return 'Under the Protection of Women from Domestic Violence Act 2005, you can approach a Protection Officer or file a complaint at the nearest police station. Helpline: 181.';
  return "I'm your AI Legal Assistant. Ask me about your rights, FIR procedures, consumer complaints, cyber crime, traffic violations, or any legal situation you're facing.";
}

module.exports = { chat };
