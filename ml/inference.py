import os
import joblib
import numpy as np
import pandas as pd


def model_fn(model_dir):
    """Load model from /opt/ml/model"""
    model_path = os.path.join(model_dir, "model.joblib")
    model = joblib.load(model_path)
    return model


def predict_fn(input_data, model):
    """
    input_data will be a JSON-like dict or a pandas-friendly structure.
    Expecting: {"instances": [value1, value2, ...]}
    """
    if isinstance(input_data, dict) and "instances" in input_data:
        X = np.array(input_data["instances"]).reshape(-1, 1)
    else:
        # fallback for CSV or raw arrays
        X = np.array(input_data).reshape(-1, 1)

    preds = model.predict(X)
    return preds.tolist()
