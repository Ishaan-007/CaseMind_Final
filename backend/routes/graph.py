from fastapi import APIRouter, HTTPException
from gemini_client import call_gemini
from prompts.graph import graph_prompt
from utils import safe_gemini_json_call

router = APIRouter(prefix="/graph", tags=["Entity Graph"])

@router.post("/build")
def build_entity_graph(case_data: dict):
    try:
        prompt = graph_prompt(case_data)
        graph_json = safe_gemini_json_call(call_gemini, prompt)
        return graph_json
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
