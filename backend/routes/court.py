from fastapi import APIRouter
from gemini_client import call_gemini
from prompts.court import court_prompt

router = APIRouter(
    prefix="/court",
    tags=["Court Narrative"]
)

@router.post("/generate-court-narrative")
def generate_narrative(case_data: dict):
    """
    Generates a neutral, court-ready narrative from case data.
    """
    prompt = court_prompt(case_data)
    narrative = call_gemini(prompt)

    return {
        "narrative": narrative.strip()
    }