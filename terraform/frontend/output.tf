output "static_website_endpoint" {
  value = "http://${var.bucketname}.s3-website-${var.region}.amazonaws.com"
}