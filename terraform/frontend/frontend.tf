# Create S3 Bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

# Configure public access settings for the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Define an S3 bucket policy to allow public read access to objects 
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.allow_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

# IAM policy document granting public read access to objects in the bucket
data "aws_iam_policy_document" "allow_public_read" {
    statement {
      sid    = "PublicReadGetObject"
      effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.bucketname}/*"
    ]
  }
}

# Upload the build folder
resource "aws_s3_object" "build" {
  for_each = fileset("../../frontend/build", "**/*")

  bucket       = aws_s3_bucket.mybucket.id
  key          = each.value
  source       = "../../frontend/build/${each.value}"
  etag         = filemd5("../../frontend/build/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "gif"  = "image/gif",
      "svg"  = "image/svg+xml",
      "json" = "application/json",
    },
    lower(regex("\\.([^.]+)$", each.value)[0]),
    "application/octet-stream"
  )
}

# Enable static website hosting for the S3 bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}