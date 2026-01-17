def consistency_prompt(case_state, new_evidence):
    return f"""
Check inconsistencies between case state and new evidence.

Case:
{case_state}

Evidence:
{new_evidence}

Return JSON:
- conflicts[]
- severity
"""
