- https://jwt.io/
- https://datatracker.ietf.org/doc/html/rfc7519: JSON Web Token (JWT)
- https://www.freecodecamp.org/news/how-to-sign-and-validate-json-web-tokens/: The header segment is base 64 URL encoded

```
# jwt

HEADER='{"alg":"HS256","typ":"JWT"}'
PAYLOAD='{"sub":"1234567890","name":"viktoya","iat":'"$(date +%s)"'}'
SECRET='segredo_super_secreto'

base64url_encode() {
  echo -n "$1" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}
HEADER_B64=$(base64url_encode "$HEADER")
PAYLOAD_B64=$(base64url_encode "$PAYLOAD")

SIGNATURE=$(echo -n "$HEADER_B64.$PAYLOAD_B64" | \
  openssl dgst -sha256 -hmac "$SECRET" -binary | \
  openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

JWT="$HEADER_B64.$PAYLOAD_B64.$SIGNATURE"
echo "JWT: $JWT"

# Decode header e payload
IFS='.' read -r HEADER_B64 PAYLOAD_B64 SIGNATURE <<< "$JWT"
echo "Header:"
echo "$HEADER_B64" | tr '_-' '/+' | base64 -d | jq
echo "Payload:"
echo "$PAYLOAD_B64" | tr '_-' '/+' | base64 -d | jq
```

```
# jwt.k8s.pod

# retrieve token
k exec -it -n kube-system kube-proxy-4wz4s -- /bin/sh # cat /var/run/secrets/kubernetes.io/serviceaccount/token

# check token expiration
token=""
exp=$(echo "$token" | cut -d '.' -f2 | base64 -d | jq -r '.exp') # for instance, "exp": 1782470618 has the unix timestamp
date -d @$exp # for instance, date -d @1782470618

# alternatively, validate token expiration via api server token review
TOKEN=$token
KUBE_API_SERVER="aks-rg2-efec8e-ohsy464e.hcp.swedencentral.azmk8s.io" # az aks show -g $rg -n aks --query fqdn -o tsv # echo $KUBERNETE# S_SERVICE_HOST
RESPONSE=$(curl -k -X POST -H "Content-Type: application/json" -d '{
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenReview",
  "spec": {
    "token": "'"$TOKEN"'"
  }
}' https://$KUBE_API_SERVER/apis/authentication.k8s.io/v1/tokenreviews)
echo $RESPONSE | jq '.status.authenticated' # true # Or "reason": "Unauthorized", "code": 401
```
