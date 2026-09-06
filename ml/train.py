import os
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import root_mean_squared_error, mean_absolute_error, r2_score
import joblib
import json
import boto3


def get_latest_file(prefix, bucket):
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)

    files = [
        obj["Key"]
        for obj in response.get("Contents", [])
        if obj["Key"].endswith(".csv")
    ]

    latest = max(files, key=lambda f: f.split("/")[-1])
    return f"s3://{bucket}/{latest}"

def main():
    output_dir = "/opt/ml/model"

    # Read bucket + prefix from environment variables passed by SageMaker
    bucket = os.environ["DATA_BUCKET_NAME"]
    prefix = os.environ["TRAINING_DATA_PREFIX"]

    # Find the latest CSV under the prefix
    latest_file_s3_uri = get_latest_file(bucket, prefix)

    # Load the CSV directly from S3
    df = pd.read_csv(latest_file_s3_uri)

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
