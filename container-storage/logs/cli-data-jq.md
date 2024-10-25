```
json='{"key1":"value1"}'; echo "$json" | jq .key1 # "value1"
json='{"key1":"value1"}'; echo "$json" | jq '.key1' # "value1"
json='[{"key1":"value1"}, {"key2":"value2"}]'; echo "$json" | jq .[0].key1 # "value1"
json='[{"key1":"value1"}, {"key2":"value2"}]'; echo "$json" | jq '.[0].key1' # "value1"
```

- https://github.com/jqlang/jq
- https://github.com/jqlang/jq/wiki
