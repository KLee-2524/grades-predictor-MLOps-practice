{
  "Version": "2020-12-01",
  "Metadata": {
    "PipelineName": "${pipeline_name}"
  },
  "Parameters": [
    {
      "Name": "InstanceType",
      "Type": "String",
      "DefaultValue": "${instance_type}"
    }
  ],
  "Steps": [
    {
      "Name": "TrainModel",
      "Type": "Training",
      "Arguments": {
        "TrainingJobName": "${training_job_name}",
        "AlgorithmSpecification": {
          "TrainingImage": "${training_image_uri}"
        },
        "InputDataConfig": [
          {
            "ChannelName": "training",
            "DataSource": {
              "S3DataSource": {
                "S3Uri": "${training_data_s3_uri}"
              }
            }
          }
        ],
        "OutputDataConfig": {
          "S3OutputPath": "${artifacts_s3_uri}"
        },
        "ResourceConfig": {
          "InstanceType": "${instance_type}",
          "InstanceCount": 1,
          "VolumeSizeInGB": 20
        },
        "RoleArn": "${role_arn}"
      }
    },
    {
      "Name": "CreateModel",
      "Type": "Model",
      "Arguments": {
        "ModelName": "${model_name}",
        "PrimaryContainer": {
          "Image": "${training_image_uri}",
          "ModelDataUrl": "${artifacts_s3_uri}"
        },
        "ExecutionRoleArn": "${role_arn}"
      }
    },
    {
      "Name": "CreateEndpointConfig",
      "Type": "EndpointConfig",
      "Arguments": {
        "EndpointConfigName": "${endpoint_config_name}",
        "ProductionVariants": [
          {
            "ModelName": "${model_name}",
            "InstanceType": "${instance_type}",
            "InitialInstanceCount": 1
          }
        ]
      }
    },
    {
      "Name": "UpdateEndpoint",
      "Type": "Endpoint",
      "Arguments": {
        "EndpointName": "${endpoint_name}",
        "EndpointConfigName": "${endpoint_config_name}"
      }
    }
  ]
}
