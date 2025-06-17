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
