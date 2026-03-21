import pickle
import numpy as np
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

def convert_pkl_to_onnx(pkl_path, onnx_path):
    # Load your .pkl model
    with open(pkl_path, 'rb') as f:
        model = pickle.load(f)
    
    print(f"Model type: {type(model)}")
    print(f"Model: {model}")
    
    # Determine the input shape (you might need to adjust this)
    # Common shapes: for single feature [1, 1], for multiple features [1, n_features]
    n_features = getattr(model, 'n_features_in_', 1)  # Try to get feature count
    
    # Define initial types (adjust based on your model)
    initial_type = [('float_input', FloatTensorType([None, n_features]))]
    
    # Convert to ONNX
    onnx_model = convert_sklearn(model, initial_types=initial_type)
    
    # Save ONNX model
    with open(onnx_path, 'wb') as f:
        f.write(onnx_model.SerializeToString())
    
    print(f"Model successfully converted to {onnx_path}")

if __name__ == "__main__":
    convert_pkl_to_onnx("surgery_priority_model.pkl", "surgery_priority_model.onnx")