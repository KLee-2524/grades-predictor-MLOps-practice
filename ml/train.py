import os
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import root_mean_squared_error, mean_absolute_error, r2_score
import joblib
import json


def main():
    input_dir = "/opt/ml/input/data/training"
    output_dir = "/opt/ml/model"

    # Find CSV file
    files = [f for f in os.listdir(input_dir) if f.endswith(".csv")]
    if not files:
        raise RuntimeError("No training CSV found in /opt/ml/input/data/training")

    csv_path = os.path.join(input_dir, files[0])
    df = pd.read_csv(csv_path)

    # Assume 2 columns: feature, target
    X = df.iloc[:, [0]].values
    y = df.iloc[:, 1].values

    model = LinearRegression()
    model.fit(X, y)

    # Predictions for metrics
    preds = model.predict(X)

    metrics = {
        "rmse": root_mean_squared_error(y, preds),
        "mae": mean_absolute_error(y, preds),
        "r2": r2_score(y, preds),
    }

    os.makedirs(output_dir, exist_ok=True)

    # Save model
    joblib.dump(model, os.path.join(output_dir, "model.joblib"))

    # Save metrics
    with open(os.path.join(output_dir, "metrics.json"), "w") as f:
        json.dump(metrics, f)


if __name__ == "__main__":
    main()
