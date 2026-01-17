def court_prompt(case_data: dict) -> str:
    return f"""
You are an AI assistant generating a court-ready case narrative.

CASE DATA:
{case_data}

GUIDELINES:
- Use neutral and professional language.
- Present facts chronologically.
- Link statements explicitly to evidence.
- Do NOT speculate or assign guilt.
- Do NOT include opinions.

OUTPUT:
A clear, structured narrative suitable for court submission.

Do NOT mention AI or Gemini.
"""
