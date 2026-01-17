def simulation_prompt(case_state):
    return f"""
Simulate two investigation paths:
Path A
Path B

Include:
- actions
- risks
- expected outcomes

Case:
{case_state}
"""
