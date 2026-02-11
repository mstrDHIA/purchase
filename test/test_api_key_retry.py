from google import genai
import os
import traceback
from dotenv import load_dotenv
import time
from google.genai.errors import ServerError

# Load .env variables if present
load_dotenv()

API_KEY = os.getenv("API_KEY")
MODEL = os.getenv("MODEL_NAME", "gemini-2.5-flash-lite")

if not API_KEY:
    print("ERREUR: API_KEY non défini. Vérifiez votre .env ou la variable d'environnement.")
else:
    client = genai.Client(api_key=API_KEY)
    max_attempts = 5
    delay = 1
    for attempt in range(1, max_attempts + 1):
        try:
            resp = client.models.generate_content(model=MODEL, contents="Hello")
            print("OK — clé valide. Réponse (extrait):", getattr(resp, 'text', str(resp))[:200])
            break
        except Exception as e:
            print(f"Tentative {attempt}/{max_attempts} échouée: {type(e).__name__}: {e}")
            if attempt == max_attempts:
                print("Erreur finale — affiche la traceback:")
                traceback.print_exc()
            else:
                time.sleep(delay)
                delay *= 2