# Website

A repository for demonstrating a full CI/CD pipeline which does the following:
1. Builds & Configures AWS environment using Terraform IaC & Python
3. Builds & Configures a Docker container for my project website
    1. The website is a Python (Flask, WSGI) application running on Apache.
4. Deploys the Docker container to the AWS environment using a GitHub Actions workflow.

## Repository Layout
**/.github/workflows** - GitHub Actions workflows

**/setup_db** - Source code (Python, JSON) for the Lambda function which populates the RDS Cluster with data

**/terraform** - IaC code for AWS environment

**/wsgi** - Application code (Python) and Apache configuration files for the project website

### This repo & the project website are a WIP.