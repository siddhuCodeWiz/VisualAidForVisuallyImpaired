# from flask import Flask, request, jsonify
# from PIL import Image
# import io
# import base64
# from yolov5 import detect  # Import the object detection function from yolov5 library

# app = Flask(__name__)

# @app.route('/detect_objects', methods=['POST'])
# def detect_objects():
#     try:
#         # Get the base64-encoded image from the request
#         print("Entered")
#         data = request.get_json()
#         encoded_image = data['image']

#         # Decode the base64-encoded image
#         image_bytes = base64.b64decode(encoded_image)

#         # Convert the bytes to a PIL Image object
#         image = Image.open(io.BytesIO(image_bytes))

#         # Perform object detection using YOLO
#         objects_detected = detect(image)

#         # Return the detected objects as JSON
#         return jsonify({'objects': objects_detected}), 200
#     except Exception as e:
#         print(e)
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)







# blip



# import requests

# API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
# headers = {"Authorization": "Bearer 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"}

# def query(filename):
#     with open(filename, "rb") as f:
#         data = f.read()
#     response = requests.post(API_URL, headers=headers, data=data)
#     print(response.json())
#     return response.json()

# output = query("C:/Users/siddh/OneDrive/Desktop/random/test_examples/child.jpg")






# from flask import Flask, request, jsonify
# import requests

# app = Flask(__name__)

# API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
# HEADERS = {"Authorization": "Bearer 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"}

# def query_model(image_data):
#     response = requests.post(API_URL, headers=HEADERS, data=image_data)
#     return response.json()

# @app.route('/caption', methods=['POST'])
# def get_image_caption():
#     try:
#         # Check if the request contains an image file
#         if 'image' not in request.files:
#             return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

#         # Read the image file from the request
#         image_file = request.files['image']
#         # print(image_file)

#         print("Content Type:", image_file.content_type)
        
#         # Query the model for image caption
#         result = query_model(image_file)
#         return jsonify(result)

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(debug=True)





# import traceback

# from flask import Flask, request, jsonify
# import base64
# import requests

# app = Flask(__name__)

# API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
# HEADERS = {"Authorization": "Bearer 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"}

# def query_model(image_data):
#     response = requests.post(API_URL, headers=HEADERS, data=image_data)
#     return response.json()

# @app.route('/caption', methods=['POST'])
# def get_image_caption():
#     try:
#         # Check if the request contains an image file
#         if 'image' not in request.form:
#             return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

#         # Get the base64-encoded image from the request
#         base64_image = request.form['image']

#         # Decode the base64-encoded image
#         image_data = base64.b64decode(base64_image)

#         # Query the model for image caption
#         result = query_model(image_data)
#         return jsonify(result)

#     except Exception as e:
#         # Print the exception traceback for debugging
#         traceback.print_exc()
#         return jsonify({'error': 'Internal Server Error'}), 500

# if __name__ == '__main__':
#     app.run(debug=True)




from flask import Flask, request, jsonify
import requests
from pymongo import MongoClient
import cloudinary.uploader
from werkzeug.utils import secure_filename
from config import Config
from werkzeug.security import generate_password_hash, check_password_hash
from bson.objectid import ObjectId
import bcrypt

class Config:
    CLOUDINARY_CLOUD_NAME = "dqooyg7dd"
    CLOUDINARY_API_KEY = '588936173388657'
    CLOUDINARY_API_SECRET = 'xqiHDl11F66V9YYg5AUheuclSmw'

    MONGODB_URI = 'mongodb://localhost:27017'  

cloudinary.config(
    cloud_name=Config.CLOUDINARY_CLOUD_NAME,
    api_key=Config.CLOUDINARY_API_KEY,
    api_secret=Config.CLOUDINARY_API_SECRET
)

# MongoDB Connection
client = MongoClient(Config.MONGODB_URI)
db = client['visualaid']
history_collection = db['images']
users_collection = db['users']

app = Flask(__name__)

API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
HEADERS = {"Authorization": "Bearer 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"}


# @app.route('/register', methods=['POST'])
# def register():
#     data = request.json
#     name = data.get('name')
#     password = data.get('password')

#     # Check if user already exists
#     if users_collection.find_one({'name': name}):
#         return jsonify({"error": "User already exists"}), 400

#     # Hash the password and store user data
#     hashed_password = generate_password_hash(password)
#     users_collection.insert_one({'name': name, 'password': hashed_password})
#     return jsonify({"message": "User registered successfully!"}), 201



# @app.route('/login', methods=['POST'])
# def login():
#     data = request.json
#     name = data.get('name')
#     password = data.get('password')

#     user = users_collection.find_one({'name': name})

#     # Validate user credentials
#     if user and check_password_hash(user['password'], password):
#         return jsonify({"message": "Login successful!"}), 200
#     else:
#         return jsonify({"error": "Invalid name or password"}), 401



@app.route('/upload', methods=['POST'])
def upload_image():
    print("entered upload")
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    caption = request.form.get('caption')
    
    if not file or not caption:
        return jsonify({'error': 'File or caption missing'}), 400
    
    # Upload the file to Cloudinary
    filename = secure_filename(file.filename)
    
    try:
        cloudinary_response = cloudinary.uploader.upload(file)
        image_url = cloudinary_response['secure_url']
        
        # Store image URL and caption in MongoDB
        history_item = {
            'image_url': image_url,
            'caption': caption
        }
        
        history_collection.insert_one(history_item)
        
        return jsonify({'message': 'Image and caption uploaded successfully', 'image_url': image_url, 'caption': caption}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Endpoint to Get All Uploaded Images and Captions (History)
@app.route('/history', methods=['GET'])
def get_history():
    history_items = history_collection.find()
    
    history_list = []
    for item in history_items:
        history_list.append({
            'image_url': item['image_url'],
            'caption': item['caption']
        })
    
    return jsonify(history_list), 200



#================= Backend for image captioning ================================
def query_model(image_data):
    response = requests.post(API_URL, headers=HEADERS, data=image_data)
    return response.json()

@app.route('/caption', methods=['POST'])
def get_image_caption():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

        image_file = request.files['image']
        print("Image : ",image_file)

        print("Content Type:", image_file.content_type)

        result = query_model(image_file)
        print(result)
        return jsonify(result[0]["generated_text"])

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    


    

@app.route('/updateresponse', methods=['POST'])
def update_response():
    data = request.json
    document_id = data.get('id')  # The document's ID
    corrected_caption = data.get('corrected_caption')  # New caption to add

    if not document_id or not corrected_caption:
        return jsonify({"error": "Invalid data"}), 400

    # Add the `corrected_caption` field with `update_one`
    result = history_collection.update_one(
        {"_id": ObjectId(document_id)},    # Filter by document ID
        {"$set": {"corrected_caption": corrected_caption}}  # Add or update `corrected_caption` field
    )

    if result.modified_count > 0:
        return jsonify({"message": "Field added successfully"}), 200
    else:
        return jsonify({"error": "No document found or update failed"}), 404

    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)