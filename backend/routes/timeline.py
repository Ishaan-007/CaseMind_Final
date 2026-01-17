from fastapi import APIRouter
from models import TimelineUpdateRequest
from gemini_client import call_gemini
from prompts.timeline import timeline_prompt
from utils import safe_gemini_json_call

router = APIRouter(prefix="/timeline", tags=["Timeline"])

@router.post("/update")
def update_timeline(request: TimelineUpdateRequest):
    """
    Updates case timeline based on new events.
    """
    prompt = timeline_prompt(
        existing_timeline=request.existing_timeline,
        new_events=request.new_events
    )

    updated = safe_gemini_json_call(call_gemini, prompt)

    return {
        "case_id": request.case_id,
        "timeline": updated
    }
