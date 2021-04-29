# Website
---

**View live project at:** http://52.73.144.56/

*Please note that the "Find Movies By Year" function may take up to 30 seconds to return an initial response. Subsequent queries will be faster.*

---

## Description
A repository for demonstrating a CI/CD pipeline which does the following:
1. Builds & Configures AWS environment using Terraform IaC & Python
3. Builds & Configures a Docker container for my project website
    1. The website is a Python (Flask, WSGI) application running on Apache.
4. Deploys the Docker container to the AWS environment using a GitHub Actions workflow.

## Repository Layout
`/.github/workflows` - GitHub Actions workflows (Build & Deploy Image, Create AWS Infrastructure)

`/setup_db` - Source code (Python, JSON) for the Lambda function which populates the RDS Cluster with data

`/terraform` - IaC code for AWS environment

`/wsgi` - Source code (Python, HTML, CSS) and Apache configuration files for the project website & its boto3 functions

### This repo & the project website are a WIP.
