FROM public.ecr.aws/docker/library/python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt /opt/ml/code/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r /opt/ml/code/requirements.txt

# Copy training and inference code
COPY train.py /opt/ml/code/train.py
COPY inference.py /opt/ml/code/inference.py

# SageMaker expects the entrypoint to be train.py for training jobs
ENV SAGEMAKER_PROGRAM train.py

# Set working directory
WORKDIR /opt/ml/code
