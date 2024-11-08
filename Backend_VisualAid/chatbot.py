# import google.generativeai as genai
# import speech_recognition as sr
# import os
# import webbrowser
# import datetime
# import pyttsx3
# import cv2
# from google.cloud import vision
# import io
# import requests

# # Set the path to your service account key file
# # os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "C:/Users/sairi/Downloads/synthetic-nova-426310-j5-440874a1c346.json"

# # Configure your Google Generative AI API key here
# genai.configure(api_key="AIzaSyAYuJjV28IcgZtdXQhisv6QZwIOdmLifV4")

# chatStr = ""
# chat_session = None


# def start_chat():
#     global chat_session
#     model = genai.GenerativeModel('models/gemini-pro')
#     chat_session = model.start_chat()


# def send_message_to_chat(message):
#     global chat_session
#     response = chat_session.send_message(message)
#     return response.text


# def send_message(query):
#     global chatStr
#     chatStr += f"sairam: {query}\nJarvis: "
#     response_text = send_message_to_chat(query)
#     say(response_text)
#     chatStr += f"{response_text}\n"
#     return response_text


# def say(text):
#     try:
#         if os.name == 'posix':  # macOS or Linux
#             os.system(f'say "{text}"')
#         elif os.name == 'nt':  # Windows
#             engine = pyttsx3.init()
#             engine.say(text)
#             engine.runAndWait()
#     except Exception as e:
#         print(f"Error in say function: {e}")


# def takeCommand():
#     r = sr.Recognizer()
#     with sr.Microphone() as source:
#         print("Listening...")
#         audio = r.listen(source)
#         try:
#             print("Recognizing...")
#             query = r.recognize_google(audio, language="en-in")
#             print(f"User said: {query}")
#             return query
#         except sr.RequestError:
#             print("Could not request results from Google Speech Recognition service")
#             return "Some Error Occurred. Sorry from Jarvis"
#         except sr.UnknownValueError:
#             print("Google Speech Recognition could not understand the audio")
#             return "Some Error Occurred. Sorry from Jarvis"

# chat_history = []  # Initialize chat history globally

# def ai(prompt):
#     model = genai.GenerativeModel('gemini-1.5-flash')
#     formatted_history = [
#         {"parts": [{"text": item["content"]}], "author": item["role"]}
#         for item in chat_history
#     ]
#     chat_session = model.start_chat(history=formatted_history)
#     text = f"Gemini response for Prompt: {prompt} \n *************************\n\n"
#     chat_history.append({"role": "user", "content": prompt})
#     response = chat_session.send_message(prompt)
#     response_text = response.text
#     chat_history.append({"role": "assistant", "content": response_text})
#     text += response_text
#     if not os.path.exists("Gemini"):
#         os.mkdir("Gemini")
#     filename_part = ''.join(prompt.split('intelligence')[1:]).strip()
#     filename_part = filename_part[:50] if len(filename_part) > 50 else filename_part
#     filename = f"Gemini/{filename_part}.txt"

#     with open(filename, "w") as f:
#         f.write(text)

# if __name__ == '__main__':
#     print('Welcome to A.I')
#     say("Hello, I am visual AI")
#     start_chat()  # Start the chat session
#     while True:
#         query = takeCommand().lower()
#         if query == "some error occurred. sorry from visual AI":
#             continue
#         sites = [["youtube", "https://www.youtube.com"], ["wikipedia", "https://www.wikipedia.com"],
#                  ["google", "https://www.google.com"]]
#         for site in sites:
#             if f"open {site[0]}" in query:
#                 say(f"Opening {site[0]} sir...")
#                 webbrowser.open(site[1])
#                 break
#         else:
#             if "play music" in query:
#                 musicPath = "C:/Users/sairi/Downloads/flow-211881.mp3"
#                 os.startfile(musicPath)
#             elif "the time" in query:
                
#                 hour = datetime.datetime.now().strftime("%H")
#                 minute = datetime.datetime.now().strftime("%M")
#                 say(f"Sir, the time is {hour} hours and {minute} minutes")
#             elif "date" in query:
#                 date = datetime.date.today()
#                 say(f"Sir, todays date is {date}")
#             elif "open camera" in query:
#                 os.system("start microsoft.windows.camera:")
#             elif "using ai" in query:
#                 ai(prompt=query)
#             elif "ai quit" in query:
#                 say("Goodbye sir.")
#                 break
#             elif "reset chat" in query:
#                 chatStr = ""
#             else:
#                 print("Chatting...")
#                 send_message(query)


















from flask import Flask, render_template, request, jsonify
import google.generativeai as genai
import pyttsx3
import os
import datetime
import requests

app = Flask(__name__)
genai.configure(api_key="AIzaSyAYuJjV28IcgZtdXQhisv6QZwIOdmLifV4")

chatStr = ""
chat_session = None

def start_chat():
    global chat_session
    model = genai.GenerativeModel('models/gemini-pro')
    chat_session = model.start_chat()

def send_message_to_chat(message):
    global chat_session
    response = chat_session.send_message(message)
    return response.text

@app.route('/')
def index():
    return render_template('index.html')

# Flask route for processing the chat
@app.route('/chat', methods=['POST'])
def chat():
    global chatStr
    user_input = request.json.get("query")
    
    if not user_input:
        return jsonify({"error": "No input provided!"}), 400
    
    # Handle different commands
    if "time" in user_input:
        hour = datetime.datetime.now().strftime("%H")
        minute = datetime.datetime.now().strftime("%M")
        response = f"The time is {hour} hours and {minute} minutes"
    elif "date" in user_input:
        date = datetime.date.today()
        response = f"Today's date is {date}"
    else:
        response_text = send_message_to_chat(user_input)
        response = response_text
    
    return jsonify({"response": response}), 200

if __name__ == '__main__':
    start_chat()  # Initialize chat session when the server starts
    app.run(host='0.0.0.0', port=5007, debug=True)
