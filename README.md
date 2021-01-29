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

### DB Secrets

For the API to access the database the following secrets must be created in the [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)

- `iatlas_api_creds_encrypted`
  with values for:
  - `dbname`
  - `host`
  - `username`
  - `password`

## Contributing

- Install [pre-commit](https://pre-commit.com/#install) app
- Clone this repo
- Run `pre-commit install` to install the git hook

## Test Deployment

[Install aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Create credentials file in your local user folder. The file should be called `credentials` located in `~/.aws`.

The contents should look like:

```credentials
[iAtlas]
aws_access_key_id = {ACCESS_KEY}
aws_secret_access_key = {SECRET_ACCESS_KEY}
region = us-west-2
```

Create config file in your local user folder. The file should be called `config` located in `~/.aws`.

The contents should look like:

```config
[default]
region = us-west-2
```

Install [Python](https://www.python.org/)

Install [sceptre-ssm-resolver](https://pypi.org/project/sceptre-ssm-resolver/)

See [https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/) for information on installing Python packages for a specific project.

[architecture]: infra-arch.svg "iAtlas architecture"
