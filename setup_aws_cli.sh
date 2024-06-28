#!/bin/bash
set -ex

# some projects deploy to multiple AWS accounts, dev/stage/prod/etc..
# we manage this by using git branches, travis vars and double interpolation
# of environment variables.
if [[ (-z ${TRAVIS_TAG+x} || ${TRAVIS_TAG} = "") && ${TRAVIS_BRANCH} != "master" ]]; then
  eval export "AwsCfServiceRoleArn=\$AwsCfServiceRoleArn_$TRAVIS_BRANCH"
  eval export "AwsTravisAccessKey=\$AwsTravisAccessKey_$TRAVIS_BRANCH"
  eval export "AwsTravisSecretAccessKey=\$AwsTravisSecretAccessKey_$TRAVIS_BRANCH"
fi

# setup the awscli with the correct aws account info.
pip install awscli
mkdir -p ~/.aws
echo -e "[default]\nregion=us-east-1\nsource_profile=default\nrole_arn=$AwsCfServiceRoleArn" > ~/.aws/config
echo -e "[default]\nregion=us-east-1\naws_access_key_id=$AwsTravisAccessKey\naws_secret_access_key=$AwsTravisSecretAccessKey" > ~/.aws/credentials
