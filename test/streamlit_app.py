import streamlit as st
from generate_test2 import generate_tests_for_code

st.set_page_config(page_title="Générateur de tests unitaires", layout="wide")
st.title("🧪 Générateur de tests unitaires")

st.markdown("Collez votre code source ci-dessous, choisissez le langage, puis cliquez sur **Générer les tests**.")

code_input = st.text_area("Code source", height=300, placeholder="Collez votre code ici...")
language = st.selectbox("Langage", ["python", "javascript", "java", "csharp", "go"], index=0)

if st.button("Générer les tests"):
    if not code_input.strip():
        st.warning("Veuillez coller du code avant de générer les tests.")
    else:
        with st.spinner("Génération en cours..."):
            try:
                tests = generate_tests_for_code(code_input, language)
                st.success("Tests générés avec succès")
                st.subheader("Tests générés")
                st.code(tests, language="python")
                st.download_button("Télécharger les tests", tests, file_name="generated_tests.py", mime="text/plain")
            except Exception as e:
                st.error(f"Erreur lors de la génération : {type(e).__name__}: {e}")
                st.exception(e)

st.markdown("---")
st.markdown("**Note:** l'appel utilise l'API Gemini de Google ; des erreurs de quota ou de disponibilité peuvent survenir.")