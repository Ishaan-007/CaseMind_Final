import os
from dotenv import load_dotenv

load_dotenv()  # <-- THIS WAS MISSING

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

if not GOOGLE_API_KEY:
    raise RuntimeError("GOOGLE_API_KEY not set in environment")

MODEL_NAME = "models/gemini-2.5-flash"
