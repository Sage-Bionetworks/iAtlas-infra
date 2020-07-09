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
