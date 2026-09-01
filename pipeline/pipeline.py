import os
import boto3
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.steps import (
    TrainingStep,
    ModelStep,
    EndpointConfigStep,
    EndpointStep,
)
from sagemaker.workflow.parameters import ParameterString
from sagemaker.sagemaker_estimator import Estimator


def get_pipeline(region, role, raw_data_s3_uri, model_bucket):
    # Parameters
    instance_type = ParameterString(name="InstanceType", default_value="ml.t3.medium")

    # Training Step
    estimator = Estimator(
        image_uri=os.environ["ECR_IMAGE_URI"],
        role=role,
        instance_count=1,
        instance_type=instance_type,
        output_path=f"s3://{model_bucket}/artifacts/",
        sagemaker_session=boto3.Session().client("sagemaker"),
    )

    train_step = TrainingStep(
        name="TrainModel", estimator=estimator, inputs={"training": raw_data_s3_uri}
    )

    # Model Step
    model_step = ModelStep(
        name="CreateModel",
        model=train_step.get_expected_model(),
        inputs=train_step.properties.ModelArtifacts,
    )

    # Endpoint Config Step
    endpoint_config_step = EndpointConfigStep(
        name="CreateEndpointConfig",
        model_name=model_step.properties.ModelName,
        instance_type="ml.t3.medium",
    )

    # Endpoint Step
    endpoint_step = EndpointStep(
        name="UpdateEndpoint",
        endpoint_name=os.environ["ENDPOINT_NAME"],
        endpoint_config_name=endpoint_config_step.properties.EndpointConfigName,
    )

    # Pipeline
    pipeline = Pipeline(
        name="students-mlops-pipeline",
        steps=[train_step, model_step, endpoint_config_step, endpoint_step],
    )

    return pipeline
