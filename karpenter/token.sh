#!/bin/bash

PROFILE="default"  # Change if using a different profile

ACCESS_KEY=$(aws configure get aws_access_key_id --profile $PROFILE)
SECRET_KEY=$(aws configure get aws_secret_access_key --profile $PROFILE)
SESSION_TOKEN=$(aws configure get aws_session_token --profile $PROFILE)

if [[ -z "$ACCESS_KEY" || -z "$SECRET_KEY" || -z "$SESSION_TOKEN" ]]; then
  echo "❌ Missing credentials for profile '$PROFILE'"
  exit 1
fi

SESSION_JSON=$(jq -n \
  --arg ak "$ACCESS_KEY" \
  --arg sk "$SECRET_KEY" \
  --arg st "$SESSION_TOKEN" \
  '{sessionId: $ak, sessionKey: $sk, sessionToken: $st}')

SIGNIN_TOKEN=$(curl -s "https://signin.aws.amazon.com/federation" \
  --data-urlencode "Action=getSigninToken" \
  --data-urlencode "Session=$SESSION_JSON" | jq -r .SigninToken)

if [[ "$SIGNIN_TOKEN" == "null" || -z "$SIGNIN_TOKEN" ]]; then
  echo "❌ Failed to retrieve SigninToken"
  exit 1
fi

DEST_URL="https://console.aws.amazon.com/"
ENCODED_DEST=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$DEST_URL'))")

LOGIN_URL="https://signin.aws.amazon.com/federation?Action=login&Issuer=aws-azure-login&Destination=$ENCODED_DEST&SigninToken=$SIGNIN_TOKEN"

echo "🔗 AWS Console Login URL:"
echo "$LOGIN_URL"
