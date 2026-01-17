import google.generativeai as genai
from config import GOOGLE_API_KEY, MODEL_NAME

genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel(MODEL_NAME)

def call_gemini(prompt: str):
    response = model.generate_content(prompt)
    print(response.text)
    return response.text
