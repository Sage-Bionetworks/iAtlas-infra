# Overview
Infrastructure to support the iAtlas project

## Design
These resources are created by sceptre:
config/common includes the vpc and network attachments for the project
config/misc launches a runner instance that can be used to interact with either database
config/staging launches an aurora postgresql resource
config/prod launches another aurora postgresql resource

## Setup
This requires secrets for database service accounts to bet set in SSM before deployment, at the path names: /iatlas-{staging,prod}/Aurora{Username,Password}

In order to create these secrets, first deploy the config/common stacks to define a KMS key to secret the strings.
