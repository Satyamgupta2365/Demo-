# llm_support.py

import requests

class LLMClient:
    def __init__(self, endpoint: str, api_key: str, model: str):
        self.endpoint = endpoint
        self.api_key = api_key
        self.model = model

    def generate(self, prompt: str, temperature: float = 0.7, top_p: float = 0.9):
        headers = {"Authorization": f"Bearer {self.api_key}"}
        payload = {
            "model": self.model,
            "prompt": prompt,
            "temperature": temperature,
            "top_p": top_p
        }
        response = requests.post(self.endpoint, json=payload, headers=headers)
        response.raise_for_status()
        return response.json().get('text', '').strip()
