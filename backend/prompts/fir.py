def fir_analysis_prompt(fir_text: str):
    return f"""
You are an AI system assisting police investigation.

STRICT RULES:
- Output ONLY valid JSON
- Do NOT include explanations
- Do NOT use markdown
- Do NOT include any text outside JSON

FIR TEXT:
{fir_text}

TASK:
1. Extract key facts
2. Map applicable BNS sections
3. Propose an investigation plan

OUTPUT FORMAT:
{{
  "key_facts": [""],
  "bns_sections": [""],
  "investigation_plan": [""]
}}
"""
