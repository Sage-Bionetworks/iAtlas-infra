# Overview
Infrastructure to support the iAtlas project

## Design
These resources are created by sceptre:
config/common includes the vpc and network attachments for the project
config/staging launches an aurora postgresql resource, gitlab runner instance, and kms key
config/prod launches another aurora postgresql resource, gitlab runner instance, and kms key

![alt text][architecture]

## Setup
This requires secrets for database service accounts to bet set in SSM before deployment,
at the path names: /iatlas/{staging,prod}/Aurora{Username,Password}

In order to create these secrets, first deploy the {staging,prod}/iatlas-kms stacks to
define a KMS key to encrypt the secret strings. Adding the strings to the parameter store
must be done manually.

The GitLab runner is an EC2 instance that can use the KMS key connected to its environment
to read secrets from the parameter store and interact with the Aurora cluster.

[architecture]: infra-arch.svg "iAtlas architecture"

## API Deployment

The API is a Docker container built in Gitlab CI, so the deployment via Elastic Beanstalk requires two files:

- The `Dockerrun.aws.json` file that specifies the application parameters to Docker
- The `iatlas-[staging|production]-dockercfg` file that tells Docker how to authenticate against the Gitlab container registry

These need to live in an S3 bucket, typically with a key prefix of the environment name (e.g. `staging/Dockerrun.aws.json`) and have ACLs on them that allow Elastic Beanstalk to read them. Examples of these files are available in the [iAtlas-API](https://gitlab.com/cri-iatlas/iatlas-api) repo.

This also assumes that a secret exists in SecretsManager that contains the RDS creds for a non-root user for the application to use. CloudFormation can't manipulate user accounts in RDS, so this needs to be done manually:

```sql
CREATE USER iatlas_api WITH PASSWORD '<yourcomplexpasswordhere>';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO iatlas_api;
```
