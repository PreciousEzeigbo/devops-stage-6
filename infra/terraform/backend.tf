# Remote state backend configuration
# Uncomment and configure for production use

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "devops-stage-6/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# To use this backend:
# 1. Create an S3 bucket for state storage
# 2. Create a DynamoDB table for state locking
# 3. Uncomment the backend configuration above
# 4. Update the bucket name and other values
# 5. Run: terraform init -migrate-state
