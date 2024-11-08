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

app = Flask(__name__)

API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
HEADERS = {"Authorization": "Bearer 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"}

def query_model(image_data):
    response = requests.post(API_URL, headers=HEADERS, data=image_data)
    return response.json()

@app.route('/caption', methods=['POST'])
def get_image_caption():
    try:
        # Check if the request contains an image file
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

        # Read the image file from the request
        image_file = request.files['image']
        print("Image : ",image_file)

        print("Content Type:", image_file.content_type)

        # Query the model for image caption
        result = query_model(image_file)
        print(result)
        return jsonify(result[0]["generated_text"])

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)




# git large
# import requests

# API_URL = "https://api-inference.huggingface.co/models/microsoft/git-large-textcaps"
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
# import base64

# app = Flask(__name__)

# API_URL = "https://api-inference.huggingface.co/models/microsoft/git-large-textcaps"
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
        
#         # Decode the image data
#         image_data = base64.b64encode(image_file.read()).decode('utf-8')

#         # Debug: Print encoded image data
#         print("Encoded Image Data:", image_data)

#         # Query the model for image caption
#         result = query_model(image_data)
#         return jsonify(result)

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(debug=True)
