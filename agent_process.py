# agent_process.py
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from llm_support import LLMClient

roles = {
    "Philosopher": "You are a deep thinking philosopher. Always reason deeply.",
    "Engineer": "You are a practical engineer. Always explain with steps and examples.",
    "Doctor": "You are a professional medical advisor. Be factual and empathetic.",
    "Lawyer": "You are a law expert. Answer strictly based on legal codes.",
    "Fitness Coach": "You are a motivational fitness coach. Always encourage action."
}

# Initialize LLM
llm_client = LLMClient(
    endpoint="https://api.groq.com/v1/completions",
    api_key="YOUR_GROQ_API_KEY",
    model="llama3-8b-8192"
)

async def handle(message):
    user_prompt = message["data"]["prompt"]
    role = message["data"]["role"]

    system_prompt = roles.get(role, "You are a helpful assistant.")
    full_prompt = f"{system_prompt}\nUser: {user_prompt}\n{role}:"

    # Call LLM
    response = llm_client.generate(full_prompt)

    return {
        "response": response
    }
