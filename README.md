# 🤖 AI Chatbot Web App

An intelligent real-time chatbot built with **Flask (Python)** and **JavaScript frontend**, powered by a **Large Language Model (LLM)**. Designed for hackathons to provide smart, instant responses to user queries!

---

## ✨ Features

- 🔥 Real-time interaction between user and AI chatbot
- 🧠 LLM (Large Language Model) integration for smart replies
- ⚡ Lightweight Flask backend
- 🖥️ Clean JavaScript-based frontend
- 🔄 API communication using Fetch API
- 🔓 CORS enabled for frontend-backend communication
- 🎯 Easy to customize with any LLM provider (OpenAI, LLaMA, Gemini, etc.)

---

## 📁 Project Structure

hack/ ├── ao_process/ │ ├── agent_process.py # Flask backend server │ ├── llm_support.py # LLM Client for generating responses ├── frontend/ │ ├── index.html # Frontend HTML │ ├── style.css # Styling for the chatbot UI │ └── script.js # Frontend JS for API calls ├── requirements.txt # Python dependencies └── README.md # Project documentation

yaml
Copy
Edit

---

## 🚀 Getting Started

### 1. Clone the Repository

2. Set up the backend
Install required Python packages:

bash
Copy
Edit
pip install -r requirements.txt
Run the Flask server:

bash
Copy
Edit
cd ao_process
python agent_process.py
Server will run on:
http://localhost:5000/

3. Set up the frontend
In a new terminal:

bash
Copy
Edit
cd frontend
# Open index.html in your browser
Or use Live Server extension in VS Code for easier browsing.

⚙️ Requirements
Python 3.8+

Flask

Flask-CORS

Web Browser (Chrome, Firefox, etc.)

🛠️ How It Works
🧑 User types a message.

📡 Message is sent to the Flask backend via a POST request.

🤖 LLM processes the message and generates a smart reply.

🧑‍💻 Frontend displays the reply in the chat interface.

💡 Future Improvements
Add persistent chat history

Integrate real LLM APIs (OpenAI / Gemini / LLaMA)

Deploy the backend and frontend online

Improve UI with animations, avatars, and themes

🤝 Contributing
Pull requests and suggestions are welcome!
Feel free to fork and improve the project.

📜 License
This project is licensed under the MIT License.

yaml
Copy
Edit
