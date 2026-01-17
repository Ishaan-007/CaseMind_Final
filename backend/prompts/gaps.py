def evidence_gap_prompt(
    case_summary: dict,
    timeline: list
) -> str:
    return f"""
You are an AI assisting police investigators.

CASE SUMMARY:
{case_summary}

CURRENT TIMELINE:
{timeline}

TASK:
1. Identify missing or weak evidence that should reasonably exist.
2. Explain why each gap matters.
3. Suggest concrete investigative actions.

OUTPUT FORMAT (STRICT JSON ONLY):
{{
  "missing_evidence": [],
  "suggested_actions": []
}}

Do NOT output explanations outside JSON.
"""
