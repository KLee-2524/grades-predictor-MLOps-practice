##############################
# S3 Buckets
##############################

# Raw data bucket
resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.resource_name_prefix}-s3-raw_data"

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-s3-raw_data"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_data_lifecycle" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    id     = "transition_raw_to_onezone"
    status = "Enabled"

    transition {
      days          = 5
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 35
    }
  }
}

# Processed data bucket
resource "aws_s3_bucket" "processed_data" {
  bucket = "${var.resource_name_prefix}-s3-processed_data"

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-s3-processed_data"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "processed_data_lifecycle" {
  bucket = aws_s3_bucket.processed_data.id

  rule {
    id     = "transition_processed_to_standard_ia"
    status = "Enabled"

    transition {
      days          = 2
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 32
    }
  }
}

# Model artifacts bucket
resource "aws_s3_bucket" "models" {
  bucket = "${var.resource_name_prefix}-s3-models"

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-s3-models"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "models_lifecycle" {
  bucket = aws_s3_bucket.models.id

  rule {
    id     = "transition_models_to_onezone"
    status = "Enabled"

    transition {
      days          = 5
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 35
    }
  }
}

# Pipeline logs bucket
resource "aws_s3_bucket" "pipeline_logs" {
  bucket = "${var.resource_name_prefix}-s3-pipeline_logs"

  tags = {
    Environment = var.environment
    Name        = "${var.resource_name_prefix}-s3-pipeline_logs"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "pipeline_logs_lifecycle" {
  bucket = aws_s3_bucket.pipeline_logs.id

  rule {
    id     = "transition_logs_to_onezone"
    status = "Enabled"

    transition {
      days          = 5
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 35
    }
  }
}

##############################
# Bucket Encryption (AES-256)
##############################

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data_enc" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_data_enc" {
  bucket = aws_s3_bucket.processed_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "models_enc" {
  bucket = aws_s3_bucket.models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_logs_enc" {
  bucket = aws_s3_bucket.pipeline_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
