from fastapi import FastAPI
import joblib

app = FastAPI()

model = joblib.load("surgery_priority_model.pkl")

@app.post("/predict")
def predict(data: dict):
    try:
        features = data["features"]

        # Ensure correct length
        if len(features) != 9:
            return {"error": "Expected 9 features"}

        prediction = model.predict([features])

        return {
            "prediction": prediction.tolist(),
            "received_features": features
        }

    except Exception as e:
        return {"error": str(e)}