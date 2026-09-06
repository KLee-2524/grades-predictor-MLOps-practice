import os
import joblib
import numpy as np
import pandas as pd
import boto3


def get_latest_file(bucket, prefix):
    """Return the S3 URI of the latest CSV under the given prefix."""
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)

    files = [
        obj["Key"]
        for obj in response.get("Contents", [])
        if obj["Key"].endswith(".csv")
    ]

    if not files:
        raise RuntimeError(f"No CSV files found under prefix: {prefix}")

    latest = max(files, key=lambda f: f.split("/")[-1])
    return f"s3://{bucket}/{latest}"


def model_fn(model_dir):
    """Load model from /opt/ml/model (SageMaker standard)."""
    model_path = os.path.join(model_dir, "model.joblib")
    model = joblib.load(model_path)
    return model


def predict_fn(input_data, model):
    """
    Real-time endpoint inference.
    Expects: {"instances": [value1, value2, ...]}
    """
    if isinstance(input_data, dict) and "instances" in input_data:
        X = np.array(input_data["instances"]).reshape(-1, 1)
    else:
        X = np.array(input_data).reshape(-1, 1)

    preds = model.predict(X)
    return preds.tolist()


def run_batch_inference(model):
    """
    Batch inference for SageMaker Pipeline.
    Loads the latest hours_studied.csv from S3,
    runs predictions, and writes grade_predictions.csv back to S3.
    """
    bucket = os.environ["DATA_BUCKET_NAME"]
    prefix = os.environ["INFERENCE_INPUTS_PREFIX"]
    output_prefix = os.environ["PREDICTIONS_PREFIX"]

    # Find latest inference CSV
    latest_file_s3_uri = get_latest_file(bucket, prefix)
    df = pd.read_csv(latest_file_s3_uri)

    # Expecting one column: hours studied
    X = df.iloc[:, [0]].values
    preds = model.predict(X)

    # Write predictions to S3
    output_path = f"s3://{bucket}/{output_prefix}grade_predictions.csv"
    df_out = pd.DataFrame({"grade_prediction": preds})
    df_out.to_csv(output_path, index=False)

    return output_path
