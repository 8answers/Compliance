const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const nutrientNames = [
  'Energy (Calories)',
  'Protein',
  'Carbohydrate',
  'Total Fat',
  'Saturated Fat',
  'Monounsaturated Fat',
  'Polyunsaturated Fat',
  'Omega-3 Fatty Acids',
  'Omega-6 Fatty Acids',
  'Dietary Fiber',
  'Total Sugar',
  'Calcium',
  'Phosphorus',
  'Magnesium',
  'Iron',
  'Zinc',
  'Copper',
  'Manganese',
  'Selenium',
  'Iodine',
  'Chromium',
  'Molybdenum',
  'Vitamin B1',
  'Vitamin B2',
  'Vitamin B3',
  'Vitamin B5',
  'Vitamin B6',
  'Vitamin B7',
  'Vitamin B9',
  'Vitamin B12',
  'Vitamin C',
  'Vitamin A',
  'Vitamin D',
  'Vitamin E',
  'Vitamin K',
];

const foodGroups = [
  'Cereals & Millets',
  'Pulses & Legumes',
  'Milk & Dairy',
  'Protein Sources',
  'Vegetables',
  'Nuts & Seeds',
  'Healthy Fats & Oils',
  'Fruits',
];

const auditSchema = {
  type: 'object',
  required: [
    'complianceScore',
    'nutritionScore',
    'mealDiversityScore',
    'nutrientAnalysis',
    'foodGroupCoverage',
    'deficiencies',
    'recommendations',
  ],
  properties: {
    complianceScore: {
      type: 'integer',
    },
    nutritionScore: {
      type: 'integer',
    },
    mealDiversityScore: {
      type: 'integer',
    },
    nutrientAnalysis: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'required', 'estimated', 'compliancePercent'],
        properties: {
          name: {
            type: 'string',
            enum: nutrientNames,
          },
          required: {
            type: 'string',
          },
          estimated: {
            type: 'string',
          },
          compliancePercent: {
            type: 'number',
          },
        },
      },
    },
    foodGroupCoverage: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'totalPercent', 'compliantPercent'],
        properties: {
          name: {
            type: 'string',
            enum: foodGroups,
          },
          totalPercent: {
            type: 'number',
          },
          compliantPercent: {
            type: 'number',
          },
        },
      },
    },
    deficiencies: {
      type: 'array',
      items: {
        type: 'string',
      },
    },
    recommendations: {
      type: 'array',
      items: {
        type: 'string',
      },
    },
  },
};

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const apiKey =
    Deno.env.get('GEMINI_API_KEY') ?? Deno.env.get('GOOGLE_API_KEY');
  if (!apiKey) {
    return jsonResponse({ error: 'GEMINI_API_KEY is not configured' }, 500);
  }

  const model = Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.5-flash';
  const body = await request.json().catch(() => null);
  const draft = body?.draft;
  if (!draft) {
    return jsonResponse({ error: 'Missing draft payload' }, 400);
  }

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: buildGeminiParts(draft),
          },
        ],
        generation_config: {
          response_mime_type: 'application/json',
          response_schema: auditSchema,
        },
      }),
    },
  );

  const geminiPayload = await response.json().catch(() => null);
  if (!response.ok) {
    return jsonResponse(
      {
        error: 'Gemini audit generation failed',
        details: geminiPayload,
      },
      response.status,
    );
  }

  const report = extractGenerateContentReport(geminiPayload);
  if (!report) {
    return jsonResponse({ error: 'Gemini returned an empty audit' }, 502);
  }

  return jsonResponse(report, 200);
});

function buildGeminiParts(draft: Record<string, unknown>) {
  const parts: Array<Record<string, unknown>> = [
    { text: buildPrompt(draftForPrompt(draft)) },
  ];
  const inlinePart = buildInlineMenuPart(draft);
  if (inlinePart) {
    parts.push(inlinePart);
  }
  return parts;
}

function draftForPrompt(draft: Record<string, unknown>) {
  const { menuFileBase64Data: _menuFileBase64Data, ...safeDraft } = draft;
  return {
    ...safeDraft,
    menuFileAttached:
      typeof draft.menuFileBase64Data === 'string' &&
      draft.menuFileBase64Data.trim().isNotEmpty,
  };
}

function buildInlineMenuPart(draft: Record<string, unknown>) {
  const mimeType = stringValue(draft.menuFileMimeType);
  const base64Data = stringValue(draft.menuFileBase64Data);
  if (!mimeType || !base64Data) {
    return null;
  }

  return {
    inline_data: {
      mime_type: mimeType,
      data: base64Data,
    },
  };
}

function stringValue(value: unknown) {
  return typeof value === 'string' ? value.trim() : '';
}

function buildPrompt(draft: Record<string, unknown>) {
  return `
You are a nutrition compliance auditor for Indian institutional menus.
Return only valid JSON matching the provided schema.
Use Indian standards from ICMR/NIN 2020 Dietary Guidelines for Indians, ICMR/NIN 2020 RDA and EAR, and FSSAI 2020 Recommended Dietary Allowance.
Do not invent unsupported citations in the JSON.

Generate a nutritional audit report for this Indian institutional menu.

Inspection context:
${JSON.stringify(draft, null, 2)}

Reference standards:
- DIETARY GUIDELINES FOR INDIANS - ICMR | NIN - 2020
- RDA and EAR - ICMR | NIN - 2020
- Recommended Dietary Allowance (RDA) - FSSAI - 2020

Rules:
- Required and estimated nutrient values must represent the average of all meals served per day.
- Use age group(s), diet type(s), region, and meals served to estimate required daily needs.
- If multiple age groups are selected, average the relevant daily requirements.
- Estimate menu nutrition from typed menu text or the attached uploaded menu file.
- If an uploaded image or PDF is attached, read the visible menu text from that file first.
- Include every nutrient exactly once and in this exact list: ${nutrientNames.join(', ')}.
- Include every food group exactly once and in this exact list: ${foodGroups.join(', ')}.
- For every food group, totalPercent must be exactly 100.
- For every food group, compliantPercent is how much of the 100% food-group target is covered by the menu.
- compliancePercent is estimated / required * 100, capped only when medically sensible.
- Scores are integers from 0 to 100.
- deficiencies must list concrete food groups or nutrients that need correction.
- recommendations must contain 5 to 6 concise, actionable menu improvement points.
- Keep required and estimated values as strings with units, for example "2200 kcal", "55 g", "600 mg", "2.4 mcg", or "100%".
`;
}

function extractGenerateContentReport(payload: unknown) {
  return findReport(payload);
}

function findReport(value: unknown, depth = 0): unknown {
  if (depth > 8 || value == null) {
    return null;
  }

  if (typeof value === 'string') {
    return parseReportText(value);
  }

  if (Array.isArray(value)) {
    for (const item of value) {
      const report = findReport(item, depth + 1);
      if (report) {
        return report;
      }
    }
    return null;
  }

  if (typeof value !== 'object') {
    return null;
  }

  if (isReportObject(value)) {
    return value;
  }

  for (const nestedValue of Object.values(value as Record<string, unknown>)) {
    const report = findReport(nestedValue, depth + 1);
    if (report) {
      return report;
    }
  }

  return null;
}

function parseReportText(text: string): unknown {
  const trimmed = text
    .trim()
    .replace(/^```(?:json)?/i, '')
    .replace(/```$/i, '')
    .trim();

  if (!trimmed) {
    return null;
  }

  const candidates = [trimmed];
  const firstBrace = trimmed.indexOf('{');
  const lastBrace = trimmed.lastIndexOf('}');
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    candidates.push(trimmed.slice(firstBrace, lastBrace + 1));
  }

  for (const candidate of candidates) {
    try {
      const parsed = JSON.parse(candidate);
      if (isReportObject(parsed)) {
        return parsed;
      }
      const nestedReport = findReport(parsed);
      if (nestedReport) {
        return nestedReport;
      }
    } catch {
      // Try the next candidate.
    }
  }

  return null;
}

function isReportObject(value: unknown) {
  if (!value || typeof value !== 'object') {
    return false;
  }

  const object = value as Record<string, unknown>;
  return (
    'complianceScore' in object &&
    'nutritionScore' in object &&
    'mealDiversityScore' in object &&
    'nutrientAnalysis' in object &&
    'foodGroupCoverage' in object &&
    'deficiencies' in object &&
    'recommendations' in object
  );
}

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
