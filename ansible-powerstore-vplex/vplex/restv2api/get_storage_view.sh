VPLEX=vplex-sim:11443
user=service
password=Mi@Dim7T
echo "API used: https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/demo_module3_sv_rest"
curl -k -X GET -u $user:$password "https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/demo_module3_sv_rest" | jq '.'
