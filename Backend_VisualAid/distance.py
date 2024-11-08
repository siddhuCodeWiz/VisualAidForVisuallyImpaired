from flask import Flask, request, jsonify
import numpy as np
from transformers import pipeline
import cv2
from PIL import Image
import io

app = Flask(__name__)

# Load the pipelines (initialize once when the app starts)
depth_estimator = pipeline("depth-estimation", model="Intel/dpt-large", framework="pt")
object_detector = pipeline("object-detection", model="facebook/detr-resnet-50", framework="pt")

# Function to estimate distance
def estimate_distance(img_data, object_width=0.5, focal_length=50, confidence_threshold=0.3, fallback_depth=10.0):
    # Convert the image data from the request into an OpenCV image
    img_array = np.frombuffer(img_data, np.uint8)
    img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Invalid image data")

    # Convert the image from BGR to RGB for PIL processing
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_pil = Image.fromarray(img_rgb)

    # Detect objects in the image
    detected_objects = object_detector(img_pil)

    # Estimate depth for the image
    result = depth_estimator(img_pil)
    depth_map = np.array(result['predicted_depth'][0])

    distances = {}

    for obj in detected_objects:
        if obj['score'] < confidence_threshold:
            continue

        label = obj['label']
        box = obj['box']
        xmin, ymin, xmax, ymax = int(box['xmin']), int(box['ymin']), int(box['xmax']), int(box['ymax'])
        object_depth = depth_map[ymin:ymax, xmin:xmax].flatten()
        valid_depth_values = object_depth[(~np.isnan(object_depth)) & (object_depth > 0)]

        # If valid depth values exist, calculate average depth, otherwise use fallback
        avg_depth = np.nanmean(valid_depth_values) if len(valid_depth_values) > 0 else fallback_depth
        distance = (object_width * focal_length) / avg_depth if avg_depth > 0 else fallback_depth

        # Store the detected objects and distances
        if label not in distances:
            distances[label] = {'count': 0, 'distances': []}

        distances[label]['count'] += 1

        if distance not in distances[label]['distances']:
            distances[label]['distances'].append(distance)

    return distances


# Flask route to handle the image upload and return distances
@app.route('/estimate_distance', methods=['POST'])
def estimate_distance_route():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    # Get the image from the request without saving it
    image_file = request.files['image']
    img_data = image_file.read()

    try:
        # Pass the image data directly to the estimate_distance function
        distances = estimate_distance(img_data)
        print(distances)
        return jsonify(distances), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Start the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True)
