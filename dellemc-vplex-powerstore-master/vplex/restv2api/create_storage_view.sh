VPLEX=vplex-sim:11443
user=service
password=Mi@Dim7T
body='{"initiators":[],"operational_status":"stopped","port_name_enabled_status":[],"ports":[],"virtual_volumes":[],"write_same_16_enabled":true,"xcopy_enabled":true,"name":"demo_module3_sv_rest"}'
echo "API used: https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/"
curl -k -X POST -d $body -H 'Content-Type: application/json' -u $user:$password "https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/" | jq '.'
