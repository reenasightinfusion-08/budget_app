const { aiHubUrl, aiHubSecret } = require('../config');

const TIMEOUT_MS = 45000;

// Only the host goes into error messages, so a wrong AI_HUB_URL is easy to spot.
const hubHost = () => {
  try {
    return new URL(aiHubUrl).host;
  } catch {
    return `invalid URL "${aiHubUrl}"`;
  }
};

const systemPrompt =
  'You read money notes for Budgie, an Indian budgeting app. Amounts are in rupees. ' +
  'Reply with JSON only: { documentType, entries: [{ type, amount, category, note, date }] }. ' +
  "Use only the category keys given. Work out dates from 'today' and never go past it. " +
  'If a photo or PDF is attached, read it. Receipt: one entry for the amount paid. Statement: one entry per row, debits are ' +
  'expense, credits are income, skip balance rows, at most 80 entries.';

// Asks ai-hub to read the text. Returns { provider, documentType, entries } with amounts still in
// rupees, or { error } when ai-hub is not configured or fails (the caller falls back to the rules parser).
module.exports = async function askAiHub({ today, inputType, text, file, categories }) {
  if (!aiHubUrl) {
    console.error('[smart-add] AI_HUB_URL is not set');
    return { error: 'AI_HUB_URL is not set on the server' };
  }

  try {
    const res = await fetch(`${aiHubUrl}/api/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(aiHubSecret && { 'x-ai-hub-secret': aiHubSecret }),
      },
      body: JSON.stringify({
        systemPrompt,
        prompt: JSON.stringify({ today, inputType, ...(text && { text }), categories }),
        format: 'json',
        ...(file && { files: [file] }),
      }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    const body = await res.json();
    if (!res.ok || !body.success || !body.data || !Array.isArray(body.data.entries)) {
      console.error('[smart-add] ai-hub replied', res.status, JSON.stringify(body).slice(0, 300));
      return { error: `ai-hub at ${hubHost()} replied ${res.status}: ${String(body.error || body.message || 'unexpected reply').slice(0, 150)}` };
    }
    return {
      provider: body.provider || null,
      documentType: body.data.documentType,
      entries: body.data.entries,
    };
  } catch (e) {
    console.error('[smart-add] ai-hub call failed:', e.message);
    return { error: `ai-hub at ${hubHost()} call failed: ${e.message}`.slice(0, 200) };
  }
};
