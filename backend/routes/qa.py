from fastapi import APIRouter
from models import CaseQuestionRequest, CaseAnswerResponse
from gemini_client import call_gemini
from prompts.qa import qa_prompt

router = APIRouter(prefix="/qa", tags=["Case Q&A"])


@router.post("/ask", response_model=CaseAnswerResponse)
def ask_case_question(request: CaseQuestionRequest):
    """
    Answers questions strictly from case data.
    """
    prompt = qa_prompt(request.case_data, request.question)
    answer_text = call_gemini(prompt)

    return CaseAnswerResponse(
        answer=answer_text.strip(),
        justification="Answer derived strictly from provided case data."
    )
