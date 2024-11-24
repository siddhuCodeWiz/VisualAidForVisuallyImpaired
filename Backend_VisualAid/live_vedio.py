# from flask import Flask, request, jsonify
# import requests

# app = Flask(__name__)

# API_URL = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"
# HEADERS = {"Authorization": "Bearer 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"}



# #================= Backend for image captioning ================================
# def query_model(image_data):
#     response = requests.post(API_URL, headers=HEADERS, data=image_data)
#     return response.json()

# @app.route('/caption', methods=['POST'])
# def get_image_caption():
#     try:
#         if 'image' not in request.files:
#             return jsonify({'error': 'No image file provided. Make sure to include an image file in the request.'}), 400

#         image_file = request.files['image']
#         print("Image : ",image_file)

#         print("Content Type:", image_file.content_type)

#         result = query_model(image_file)
#         print(result)
#         return jsonify(result[0]["generated_text"])

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500 

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5010, debug=True)








# from flask import Flask, request, jsonify
# from transformers import BlipProcessor, BlipForConditionalGeneration
# from PIL import Image
# import io
# import torch

# app = Flask(__name__)

# # Load the model and processor once to serve multiple requests
# model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")
# processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")

# def generate_caption(image_data):
#     image = Image.open(io.BytesIO(image_data))
#     inputs = processor(images=image, return_tensors="pt")

#     with torch.no_grad():
#         output_ids = model.generate(**inputs)
#     caption = processor.decode(output_ids[0], skip_special_tokens=True)
#     return caption

# @app.route('/caption', methods=['POST'])
# def get_image_caption():
#     if 'image' not in request.files:
#         return jsonify({'error': 'No image file provided.'}), 400

#     image_file = request.files['image']
#     image_data = image_file.read()
#     caption = generate_caption(image_data)
#     return jsonify({"generated_text": caption})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5010)








from flask import Flask, request, jsonify
from transformers import BlipProcessor, BlipForConditionalGeneration
from PIL import Image
import io
import torch

app = Flask(__name__)

# Check if GPU is available
device = "cuda" if torch.cuda.is_available() else "cpu"

# Load model and processor
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large").to(device)
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")

# Enable half-precision if using GPU
if device == "cuda":
    model = model.half()

def generate_caption(image_data):
    image = Image.open(io.BytesIO(image_data)).resize((256, 256))  # Resize to reduce processing time
    inputs = processor(images=image, return_tensors="pt").to(device)

    with torch.no_grad():
        output_ids = model.generate(**inputs)
    caption = processor.decode(output_ids[0], skip_special_tokens=True)
    return caption

@app.route('/caption', methods=['POST'])
def get_image_caption():
    print(device)
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided.'}), 400

    image_file = request.files['image']
    image_data = image_file.read()
    caption = generate_caption(image_data)
    return jsonify({"generated_text": caption})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5010)
