🤖 AI Chatbot Web App
An intelligent real-time chatbot built with Flask (Python) and JavaScript frontend, powered by a Large Language Model (LLM). Designed for hackathons to provide smart, instant responses to user queries!

✨ Features
🔥 Real-time interaction between user and AI chatbot

🧠 LLM (Large Language Model) integration for smart replies

⚡ Lightweight Flask backend

🖥️ Clean JavaScript-based frontend

🔄 API communication using Fetch API

🔓 CORS enabled for frontend-backend communication

🎯 Easy to customize with any LLM provider (OpenAI, LLaMA, Gemini, etc.)

📁 Project Structure
bash
Copy
Edit
hack/
├── ao_process/
│   ├── agent_process.py       # Flask backend server
│   ├── llm_support.py          # LLM Client for generating responses
├── frontend/
│   ├── index.html              # Frontend HTML
│   ├── style.css               # Styling for the chatbot UI
│   └── script.js               # Frontend JS for API calls
├── requirements.txt            # Python dependencies
└── README.md                   # Project documentation
🚀 Getting Started
1. Clone the Repository
bash
Copy
Edit
git clone https://github.com/your-username/your-repo.git
cd hack
2. Set up the Backend
Install dependencies:

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
3. Set up the Frontend
In a new terminal:

bash
Copy
Edit
cd frontend
# Open index.html in your browser
(You can also serve it with a simple local server like Live Server in VS Code.)

⚙️ Requirements
Python 3.8+

Flask

Flask-CORS

HTML, CSS, JavaScript (no extra libraries required for frontend)

🛠️ How it Works
The user types a message in the frontend.

The frontend sends the message to the Flask backend using fetch().

The backend processes it with the LLM and sends the bot's reply.

The frontend displays the response in the chat window.

💡 Future Improvements
Add conversation history

Deploy on Render/Vercel

Add user authentication

Improve UI/UX with animations and bot avatars

🤝 Contributing
Feel free to open issues or pull requests to improve the project!

📜 License
This project is under MIT License.
