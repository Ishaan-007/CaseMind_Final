def timeline_prompt(existing_timeline, new_events):
    return f"""
You are an AI system updating a police investigation timeline.

RULES (STRICT):
- Output MUST be valid JSON
- Output MUST be a JSON array
- Do NOT include explanations, markdown, or text
- Do NOT wrap in ``` fences
- Confidence MUST be one of: low, medium, high

CURRENT TIMELINE:
{existing_timeline}

NEW EVENTS:
{new_events}

TASK:
Merge new events into timeline, reorder chronologically.

OUTPUT FORMAT:
[
  {{
    "event": "",
    "time_range": "",
    "source": "FIR or Evidence",
    "confidence": "low | medium | high"
  }}
]
"""
