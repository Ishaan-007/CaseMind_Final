def graph_prompt(case_data):
    return f"""
Extract entities and relationships.

Return JSON:
nodes: [id, type]
edges: [source, target, relation]

Case:
{case_data}
"""
