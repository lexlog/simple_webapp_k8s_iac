resource "aws_ecr_repository" "simplewebapp-test-repo-dev" {
  name                 = "simplewebapp-test-repo-dev" 
  image_tag_mutability = "MUTABLE"         
  image_scanning_configuration {
    scan_on_push = true                     
  }

  tags = {
    Environment = "Dev"
    Project     = "simplewebapp"
  }
}

resource "aws_ecr_repository" "simplewebapp-test-repo-prod" {
  name                 = "simplewebapp-test-repo-prod" 
  image_tag_mutability = "IMMUTABLE"         
  image_scanning_configuration {
    scan_on_push = true                     
  }

  tags = {
    Environment = "Prod"
    Project     = "simplewebapp"
  }
}