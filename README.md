# cloud-resume-infra-code

## Purpose

This repo contains all the Terraform files for building the backend infrastructure (S3 bucket, CloudFront distribution, DynamoDB, Lambda function and API Gateway) for my online resume hosted on AWS cloud.

## Requirements

Please add a .tfvars file to customize these variables:

```
my_aws_region = "ca-central-1"
bucket_name = "YOUR-BUCKET-NAME"
domain_name = "YOUR-ROOT-DOMAIN-NAME"
endpoint = "YOUR-RESUME-SITE-DOMAIN-NAME"
api_domain = "YOUR-API-DOMAIN-NAME"
project_name = "cloud-resume"
dynamodb_table_name = "cloud-resume-visitor-count"
lambda_function_name = "cloud-resume-get-visitor-count"
lambda_runtime = "python3.9"
```

## GitHub Actions

1. pre-commit:
Run through Python "pre-commit" with tools listed in the ".pre-commit-config.yaml".

2. codeql:
Static Code Analysis scan using "CodeQL". This scan focuses on the Lambda function written in Python.

3. checkov:
Static Code Analysis scan using "Checkov". This scan focuses on the Terraform (IaC) files.

4. terraform:
Run Terraform commands to deploy backend infrastructure in AWS.

5. e2e:
Run Cypress end-to-end test to check the cloud resume page and visitor count.

### Acknowledgement

1. Cloud Resume Challenge: https://cloudresumechallenge.dev/docs/the-challenge/aws/
2. Blog posts from others who completed the "Cloud Resume Challenge":
    - https://medium.com/@bryant.logan1/cloud-resume-challenge-the-backend-7d5e58e4090c
    - https://cloudresumechallenge.dev/halloffame/
3. Set up Cloudfron and S3 using Terraform: https://github.com/dyordsabuzo/pablosspot/tree/main/ep-07-setting-static-website
4. GitHub Actions workflow for pre-commit: https://thomasthornton.cloud/2022/08/04/running-pre-commit-hooks-as-github-actions/
5. Hot to manage Terraform state in S3: https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
