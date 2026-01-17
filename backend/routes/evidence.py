from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from gemini_client import model
from prompts.evidence import evidence_prompt
import json, tempfile, shutil, os, time, re
import google.generativeai as genai

router = APIRouter()


def safe_gemini_json_call(call_fn, prompt: str):
    raw = call_fn(prompt)

    # Try direct JSON
    try:
        return json.loads(raw)
    except:
        pass

    # Try extracting JSON block
    match = re.search(r'(\{.*\}|\[.*\])', raw, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except:
            pass

    raise ValueError("Unable to extract valid JSON from Gemini response")


@router.post("/process-evidence-multimodal")
async def process_evidence_multimodal(
    fir_context: str = Form(...),
    evidence_type: str = Form(...),  # image | audio | video | document
    file: UploadFile = File(...)
):
    # Save file temporarily
    suffix = os.path.splitext(file.filename)[1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        shutil.copyfileobj(file.file, tmp)
        temp_path = tmp.name

    try:
        # Upload file to Gemini
        gemini_file = genai.upload_file(path=temp_path)

        # Wait until processed
        while gemini_file.state.name == "PROCESSING":
            time.sleep(1)
            gemini_file = genai.get_file(gemini_file.name)

        if gemini_file.state.name == "FAILED":
            raise HTTPException(status_code=500, detail="Gemini failed to process file")

        # Build prompt
        prompt = evidence_prompt(fir_context, evidence_type)

        # Call Gemini with multimodal input
        def call_fn(p):
            response = model.generate_content([gemini_file, p], request_options={"timeout": 600})
            return response.text

        response_json = safe_gemini_json_call(call_fn, prompt)
        return response_json

    finally:
        os.remove(temp_path)





