resource "aws_ecr_repository" "mytomorrows-test-repo-dev" {
  name                 = "mytomorrows-test-repo-dev" 
  image_tag_mutability = "MUTABLE"         
  image_scanning_configuration {
    scan_on_push = true                     
  }

  tags = {
    Environment = "Dev"
    Project     = "mytomorrows"
  }
}

resource "aws_ecr_repository" "mytomorrows-test-repo-prod" {
  name                 = "mytomorrows-test-repo-prod" 
  image_tag_mutability = "IMMUTABLE"         
  image_scanning_configuration {
    scan_on_push = true                     
  }

  tags = {
    Environment = "Prod"
    Project     = "mytomorrows"
  }
}