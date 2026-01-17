def qa_prompt(case_data, question):
    return f"""
Answer ONLY from case data.
If insufficient info, say "Insufficient evidence".

Case:
{case_data}

Question:
{question}
"""
