########################################
# Unified S3 Bucket for All ML Data
########################################

resource "aws_s3_bucket" "students_data" {
  bucket = var.data_bucket_name

  tags = {
    Environment = var.environment
    Name        = var.data_bucket_name
  }
}

########################################
# Optional: Lifecycle Policy
########################################

resource "aws_s3_bucket_lifecycle_configuration" "students_data_lifecycle" {
  bucket = aws_s3_bucket.students_data.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

########################################
# Encryption (AES-256)
########################################

resource "aws_s3_bucket_server_side_encryption_configuration" "students_data_enc" {
  bucket = aws_s3_bucket.students_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
