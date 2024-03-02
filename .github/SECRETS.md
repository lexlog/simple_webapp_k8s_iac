# GitHub Secrets Configuration

This document describes the required secrets and configuration for the CI/CD workflows.

## Required GitHub Secrets

Configure these in your repository: **Settings → Secrets and variables → Actions**

### AWS Credentials

| Secret Name | Description | Example |
|------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS IAM user access key with permissions for ECR, EKS, and Terraform | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM user secret access key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_ACCOUNT_ID` | Your AWS account ID (12 digits) | `123456789012` |

### Required AWS IAM Permissions

The IAM user/role needs the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

## Environment Variables

These can be set in the workflow files or as repository variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_REGION` | AWS region where resources are deployed | `us-east-1` |
| `ECR_REPOSITORY` | ECR repository name | `simplewebapp` |
| `EKS_CLUSTER_NAME` | EKS cluster name | `simplewebapp-cluster` |

## Setting Up Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings → Secrets and variables → Actions**
3. Click **New repository secret**
4. Add each secret with its corresponding value
5. Save the secret

## Verifying Configuration

After setting up secrets, you can verify the workflow by:
1. Creating a pull request (triggers CI workflow)
2. Merging to main branch (triggers CD workflow)
3. Checking workflow runs in the **Actions** tab

## Security Best Practices

- **Never commit secrets** to the repository
- **Use least privilege** IAM policies
- **Rotate credentials** regularly
- **Use GitHub Environments** for production deployments with approval gates
- **Enable branch protection** rules on main branch
- **Use OIDC** instead of access keys when possible (more secure)

## Troubleshooting

### Authentication Errors

If you see authentication errors:
- Verify AWS credentials are correct
- Check IAM user has required permissions
- Ensure AWS account ID matches your account

### ECR Push Failures

If Docker push fails:
- Verify ECR repository exists
- Check repository name matches `ECR_REPOSITORY` variable
- Ensure IAM user has ECR push permissions

### EKS Connection Issues

If kubectl commands fail:
- Verify cluster name matches `EKS_CLUSTER_NAME`
- Check IAM user has EKS describe permissions
- Ensure cluster exists in the specified region
