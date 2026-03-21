import onnxruntime as ort
import numpy as np

# Load your ONNX model
session = ort.InferenceSession('surgery_priority_model.onnx')

# Print model info
print("Inputs:", [i.name for i in session.get_inputs()])
print("Outputs:", [i.name for i in session.get_outputs()])

# Test with sample input
input_name = session.get_inputs()[0].name
output_name = session.get_outputs()[0].name

# Create test input (adjust shape based on your model)
test_input = np.array([[35.0, 120.0, 2.0, 1.0, 0.0]], dtype=np.float32)

# Run prediction
result = session.run([output_name], {input_name: test_input})
print("Test prediction:", result[0])