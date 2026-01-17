from fastapi import APIRouter, HTTPException
from prompts.fir import fir_analysis_prompt
from gemini_client import call_gemini
from utils import safe_gemini_json_call

router = APIRouter(prefix="/fir", tags=["FIR Analysis"])


@router.post("/analyze")
def analyze_fir(fir_text: str):
    try:
        prompt = fir_analysis_prompt(fir_text)
        result = safe_gemini_json_call(call_gemini, prompt)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"FIR analysis failed: {str(e)}"
        )
