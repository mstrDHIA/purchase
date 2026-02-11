
from constant_variables import API_KEY, MODEL_NAME
from langchain_core.prompts import PromptTemplate
from google import genai
import time
import traceback
from google.genai.errors import ServerError

class GeminiLLM:
    """
    Wrapper class for interacting with the Gemini API as a callable LLM.

    This class initializes a Gemini client using the provided API key and allows
    LLM inference by simply calling the instance with a prompt string.
    """
    def __init__(self, api_key: str):
        """
        Initialize the Gemini client.

        :param api_key: (str) Your Google Gemini API key used for authentication.
        """
        self.client = genai.Client(api_key=api_key)

    def __call__(self, prompt: str) -> str:
        """
        Send a prompt to the Gemini model and return the generated response as text.

        :param prompt: (str) The input prompt to send to the model.
        :return: (str) The generated model output text.
        """
        return self.client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt
        ).text
def get_response(template:str,metrics,lang)->str:
    """
    Function to get response from llm model using specific template to guide it to get best result
    
    :params:
        template str: contains prompt to get template for llm response
        metrics : informations to add in template
        
    :returns:
        result(str):the result of response of llm
    """
    prompt = PromptTemplate(
    input_variables=["code","language"],
    template_format="jinja2",
    template=template
    )

    formatted_prompt = prompt.format(code=metrics, language=lang)
    llm = GeminiLLM(api_key=API_KEY)

    # Retry logic for transient server errors (exponential backoff)
    max_attempts = 5
    delay = 1  # seconds
    for attempt in range(1, max_attempts + 1):
        try:
            result = llm(formatted_prompt)
            break
        except ServerError as e:
            # The service may be overloaded; retry with backoff
            if attempt == max_attempts:
                raise
            time.sleep(delay)
            delay *= 2
        except Exception:
            # Non-server-related exception: re-raise immediately
            raise

    result = result.strip("```")
    
    return result


template="""
You are an AI coding assistant.

Generate a complete and runnable unit test suite for the given source code.

### Inputs:
- Programming language: {{language}}
- Source code: {{code}}

### Rules:
- Use the standard unit testing framework for the specified language
  (examples:
   - Python → pytest
   - Java → JUnit
   - JavaScript → Jest
   - C# → xUnit
   - Go → testing package)
- Output exactly **one test file**.
- Use simple assertions.
- Do not mock unless necessary.
- Do not include explanations outside comments.

### Coverage requirements:
- Normal/valid input cases
- Edge cases:
  - null / None / undefined
  - empty input
  - invalid input types
- Error handling behavior (exceptions or failures)

### Style:
- Each test must include a short comment explaining what it checks.
- Tests must be executable without modification.
- Output **only the unit test code** (no markdown, no explanations).
### Output:
don't include ``` this markdown in your response on top and in the end of response.

"""



def generate_tests_for_code(code: str, language: str = "python") -> str:
    """Generate unit tests for the provided source code and language.

    This uses the existing `template` and `get_response` helper.
    """
    return get_response(template, code, language)


# Example usage when running this module directly
if __name__ == "__main__":
    metrics = """
def division(a, b):
    '''
    Divise deux nombres.
    Lève une exception si b == 0 ou si les types sont invalides.
    '''
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("Les deux paramètres doivent être des nombres")

    if b == 0:
        raise ValueError("Division par zéro")

    return a / b


"""
    lang = "python"
    try:
        response = generate_tests_for_code(metrics, lang)
        with open("test.txt", "w", encoding="utf-8") as f:
            f.writelines(response)
    except Exception as e:
        err_msg = f"ERROR: {type(e).__name__}: {e}\n\nTraceback:\n{traceback.format_exc()}"
        with open("test.txt", "w", encoding="utf-8") as f:
            f.write(err_msg)
        print(err_msg)