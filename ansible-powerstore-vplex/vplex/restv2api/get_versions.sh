VPLEX=vplex-sim:11443
user=service
password=Mi@Dim7T
curl -k -X GET -u $user:$password "https://$VPLEX/vplex/v2/versions" | jq '.'
