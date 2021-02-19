# Overview

Infrastructure to support the iAtlas project

## Design

These resources are created by sceptre:
config/common includes the vpc and network attachments for the project. Also launches the GitLab runner instance.
config/staging launches an aurora postgresql resource, kms key, and the api app for the staging environment.
config/prod launches an aurora postgresql resource, kms key, and the api app for the production environment.

![alt text][architecture]

## Setup

### Parameter Store

This requires secrets for database service accounts to bet set in SSM before deployment,
at the path names: /iatlas/{staging,prod}/Aurora{Username,Password}

In order to create these secrets, first deploy the {staging,prod}/iatlas-kms stacks to
define a KMS key to encrypt the secret strings. Adding the strings to the parameter store
must be done manually.

The GitLab runner is an EC2 instance that can use the KMS key connected to its environment
to read secrets from the parameter store and interact with the Aurora cluster.

### Property Store

The stacks expect the following keys to have values in the System Manager Property Store (SSM)

- `/iatlas/prod/domain_name`

  The domain name where iAtlas apps may be accessed in Prod (ie `cri-iatlas.org`).

- `/iatlas/prod/api_sub_domain_name`

  The sub domain name where iAtlas API may be accessed in Prod (ie `api` to create a full domain like `api.cri-iatlas.org`).

- `/iatlas/staging/domain_name`

  The domain name where iAtlas apps may be accessed in Staging (ie `cri-iatlas.dev`).

- `/iatlas/staging/api_sub_domain_name`

  The sub domain name where iAtlas API may be accessed in Staging (ie `api` to create a full domain like `api.cri-iatlas.dev`).

### Secrets

For the API to access the database the following secrets must be created in the [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)

- `iatlas_gitlab_registry_creds`

  with values for:
  - `username`
  - `password`

  These are readonly credentials for accessing the container registry in GitLab. The username and password (deploy token) are generated in [GitLab](https://gitlab.com/groups/cri-iatlas/-/settings/repository#js-deploy-tokens)

### Manual Deploys

The following MUST be created initially for the CI/CD to work in GitLab:

- `common/iatlas-runner.yaml`

  The GitLab runner is common and used by all builds. Creating it will also create:
  - `common/iatlasvpc.yaml`
  - `staging/iatlas-kms.yaml`
  - `staging/iatlas-api-db.yaml`
  - `prod/iatlas-kms.yaml`
  - `prod/iatlas-api-db.yaml`

  The Staging and Prod database instances are needed so that the host values for each may be passed to the GitLab Runner. The host is a subnet and not available outside the VPC.

  The KMS stacks are needed for the Databases.

  The VPC is needed for the Runners and the Databases.

- `staging/iatlas-api-hostedzone.yaml`

- `prod/iatlas-api-hostedzone.yaml`

  Once the HostedZones are created for Staging and Production, NS records may be created in the domain registrar with values from the respective HostedZones.

  ie - If the domain staging.example.com is to be used for the Staging API, create an NS record for the `staging` subdomain in the domain registrar for each of the nameservers created in the HostedZone for that domain - [route53](https://console.aws.amazon.com/route53/v2/hostedzones#).

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
