# ⭐ Kiro Steering Document — Students MLOps Project (AWS + Terraform)

**Project Owner:** Kaleb  
**Terraform Cloud Organization:** `kel-aws-org`  
**IaC Style:** Flat Terraform structure with service-specific `.tf` files + environment-specific `.tfvars`  
**Primary Goal:** Build a fully production-grade MLOps pipeline for a simple regression use case (Hours Studied → Test Grade) using AWS SageMaker, Terraform, and GitHub Actions.

---

## 1. Project Objectives

- Build an enterprise-style MLOps workflow around a simple ML model.
- Use AWS SageMaker for:
  - Custom training (`train.py`)
  - Custom inference (`inference.py`)
  - Model Registry
  - Endpoint deployment
- Use Terraform (flat structure) to define all infrastructure.
- Use Terraform Cloud (single workspace) with environment-specific `.tfvars`.
- Use GitHub Actions for CI/CD (Docker build + ECR push + Terraform Cloud runs).
- Trigger training automatically when a new yearly CSV is uploaded to S3.
- Deploy a real-time SageMaker endpoint for inference.
- Add CloudWatch logging + alarms for observability.

---

## 2. Environments

Current environments:
- **dev**
- **prd**

Future environments:
- **qa**
- **sdx** (sandbox)

Environment separation is handled via:
- `envs/dev.tfvars`
- `envs/prd.tfvars`
- Terraform Cloud workspace: **one workspace per repo** (Option A)

---

## 3. Naming Convention

All AWS resources follow: kel-{env}-{resource}-{descriptive_name}

Examples:
- `kel-dev-s3-raw_data`
- `kel-prd-sagemaker-endpoint-students`
- `kel-dev-ecr-students_model`

This naming convention applies to:
- S3 buckets
- IAM roles
- ECR repositories
- SageMaker pipelines
- SageMaker endpoints
- CloudWatch alarms
- EventBridge rules

---

## 4. AWS Region

All resources deployed to: us-west-2

---

## 5. Terraform Structure (Flat Style)

Your org’s standard structure:

terraform/
    providers.tf
    variables.tf

    s3.tf
    iam.tf
    ecr.tf
    sagemaker_training.tf
    sagemaker_endpoint.tf
    sagemaker_registry.tf
    sagemaker_pipeline.tf
    eventbridge.tf
    cloudwatch.tf

    envs/
        dev.tfvars
        prd.tfvars


Key characteristics:
- No `main.tf` (your org does not use it).
- Terraform Cloud handles backend + state.
- All resources declared directly in service-specific `.tf` files.
- `.tfvars` contain **all** environment-specific values.

---

## 6. Terraform Cloud Configuration

Terraform Cloud Organization: kel-aws-org

Workspace strategy:
- **One workspace per repo** (Option A)
- Workspace name example: `students-mlops`

Environment-specific values are passed via:
- `envs/dev.tfvars`
- `envs/prd.tfvars`

GitHub Actions triggers:

terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars

---

## 7. ML Code Structure

ml/
train.py
inference.py
Dockerfile

### Training
- Custom training logic in `train.py`
- Runs inside a custom Docker container
- Container stored in ECR
- SageMaker Training Job pulls image from ECR

### Inference
- Custom inference logic in `inference.py`
- SageMaker endpoint uses same (or separate) container

---

## 8. Data Flow

### Input Data
Yearly CSV uploaded to: kel-{env}-s3-raw_data

Columns:
- `hours_studied`
- `test_grade`

### Trigger
S3 PUT → EventBridge → SageMaker Pipeline → Training Job

### Output
- Processed data → `kel-{env}-s3-processed_data`
- Model artifacts → `kel-{env}-s3-models`
- Metrics → `kel-{env}-s3-models/metrics.json`
- Registered model → SageMaker Model Registry
- Deployment → SageMaker Endpoint

---

## 9. SageMaker Pipeline Steps

1. **Data Validation & Preprocessing**
2. **Training Job (custom container)**
3. **Evaluation (metrics JSON)**
4. **Model Registration**
5. **Conditional Deployment to Endpoint**
6. **CloudWatch Logging**

Pipeline defined in: sagemaker_pipeline.tf

---

## 10. EventBridge Trigger

EventBridge rule:
- Trigger on S3 PUT for yearly CSV uploads
- Target: SageMaker Pipeline execution

Defined in: eventbridge.tf

---

## 11. CloudWatch Logging & Alarms

CloudWatch components:
- Logs for training jobs
- Logs for endpoint invocation
- Alarms for:
  - Endpoint errors
  - High latency
  - Training job failures

Defined in: cloudwatch.tf

---

## 12. ECR

ECR repository for ML container: kel-{env}-ecr-students_model

Used by:
- Training job
- Inference endpoint

Defined in: ecr.tf

---

## 13. IAM Roles

IAM roles needed:
- SageMaker execution role
- Pipeline execution role
- EventBridge → SageMaker role
- ECR pull role
- CloudWatch logging role

Defined in: iam.tf

---

## 14. Next Steps

Now that the steering document is complete, the next phase is:

### **Phase 1 — Generate Terraform Skeleton**
We will create:

- `providers.tf`
- `variables.tf`
- `envs/dev.tfvars`
- `envs/prd.tfvars`

Then proceed to:

### **Phase 2 — S3 + IAM**  
### **Phase 3 — ECR + Docker**  
### **Phase 4 — SageMaker Training**  
### **Phase 5 — SageMaker Endpoint**  
### **Phase 6 — Model Registry**  
### **Phase 7 — Pipeline**  
### **Phase 8 — EventBridge Trigger**  
### **Phase 9 — CloudWatch Logging + Alarms**

---
