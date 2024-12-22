# ベースイメージを指定
FROM node:14-alpine

RUN apk add --no-cache curl jq

RUN npm install -g openapi-to-postmanv2

WORKDIR /

ENV POSTMAN_API_URL="https://api.getpostman.com/collections"

# 実行コマンド
CMD sh -c '\
  openapi2postmanv2 -s "${OPENAPI_FILE_PATH}" -o /postman_collection.json -p && \
  params=${PATHPARAMETERS} && \
  for PARAM in $params; do \
    sed -i "s/:${PARAM}/{{$PARAM}}/g" /postman_collection.json; \
  done && \
  if jq empty /postman_collection.json >/dev/null 2>&1; then \
    jq "{collection: .}" /postman_collection.json > /postman_collection_wrapped.json; \
  else \
    echo "Error: Invalid JSON format in /postman_collection.json"; exit 1; \
  fi && \
  curl --location --request PUT "${POSTMAN_API_URL}/${POSTMAN_COLLECTION_ID}" \
    --header "X-Api-Key: ${POSTMAN_API_KEY}" \
    --header "Content-Type: application/json" \
    --data @/postman_collection_wrapped.json'
