#!/bin/bash

# Create an auth method
AUTH_METHOD_ID=$(boundary auth-methods create password \
    -name="hashiconf-eu-22" \
    -description="auth method for global scope" \
    -scope-id=global \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq -r '.item.id')

# Create Account
ACCOUNT_ID=$(boundary accounts create password -login-name=admin \
     -description "Password account for admin user" \
     -password="password" \
     -auth-method-id=${AUTH_METHOD_ID} \
     -recovery-config="./config/recovery.hcl" \
     -format="json" | jq -r '.item.id')

# create user
USER_ID=$(boundary users create -name="admin" \
    -description="admin user for global scope" \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq -r '.item.id')

# Add account to user
boundary users set-accounts \
    -account=${ACCOUNT_ID} \
    -id=${USER_ID} \
    -version=1 \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq 

# Create admin role
ROLE_ID=$(boundary roles create -name="admin" \
    -scope-id="global" \
    -description="admin role for global scope" \
    -grant-scope-id="global" \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq -r '.item.id')

# Add grant strings
boundary roles add-grants \
    -grant="id=*;type=*;actions=*" \
    -id=r_4fqtPAKYvD \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq

#Add user to role
boundary roles add-principals \
    -id=${ROLE_ID} \
    -principal=${USER_ID} \
    -recovery-config="./config/recovery.hcl" \
    -format="json" | jq

