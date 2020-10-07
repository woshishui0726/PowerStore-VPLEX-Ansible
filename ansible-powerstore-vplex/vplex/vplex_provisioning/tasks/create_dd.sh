VPLEX=172.16.1.100
user=service
password=Password123
CG=DistCG1
StorageView=vcunity02_idm
distributed_device=device_Ansible_dd
#this should match variable "create_device_name" in host_vars/ansible.yaml, but suffix is added by some python code..
device_cluster1_leg1=Ansible_device_VPLEX_2GB_leg1_1
#this should match variable "create_device_name2" in host_vars/ansible.yaml, but suffix is added by some python code..
device_cluster2_leg2=Ansible_device_VPLEX_2GB_leg2_1

#Creates a distributed device
bodyDDtemp=\'{\"name\":\"${distributed_device}\",\"primary_leg\":\"/vplex/v2/clusters/cluster-1/devices/$device_cluster1_leg1\",\"secondary_leg\":\"/vplex/v2/clusters/cluster-2/devices/$device_cluster2_leg2\",\"rule_set\":null,\"sync\":false}\'
bodyDD=$(echo $bodyDDtemp | sed s/\'//g)
echo "API used: https://$VPLEX/vplex/v2/distributed_storage/distributed_devices/"
echo $bodyDD
curl -k -X POST -d $bodyDD -H 'Content-Type: application/json' -u $user:$password "https://$VPLEX/vplex/v2/distributed_storage/distributed_devices/" | jq '.'

#Creates a distributed volume (for future host export)
bodyDVtemp=\'{\"tier\":null,\"thin\":false,\"init\":false,\"device\":\"/vplex/v2/distributed_storage/distributed_devices/$distributed_device\"}\'
bodyDV=$(echo $bodyDVtemp | sed s/\'//g)
#echo "API used: https://$VPLEX/vplex/v2/distributed_storage/distributed_virtual_volumes/"
curl -k -X POST -d $bodyDV -H 'Content-Type: application/json' -u $user:$password "https://$VPLEX/vplex/v2/distributed_storage/distributed_virtual_volumes/" | jq '.'

#Adds the distributed volume to the distributed Consistency Group "CG"
bodyCGtemp=\'[{\"op\":\"add\",\"path\":\"/virtual_volumes\",\"value\":\"/vplex/v2/distributed_storage/distributed_virtual_volumes/${distributed_device}_vol\"}]\'
bodyCG=$(echo $bodyCGtemp | sed s/\'//g)
#echo "API used: https://$VPLEX/vplex/v2/distributed_storage/distributed_consistency_groups/Distributed_CG/"
curl -k -X PATCH -d $bodyCG -H 'Content-Type: application/json' -u $user:$password "https://$VPLEX/vplex/v2/distributed_storage/distributed_consistency_groups/$CG/" | jq '.'

#Adds the distributed volume to the Storage View on cluster-1 "StorageView"
bodyAddSVtemp=\'[{\"op\":\"add\",\"path\":\"/virtual_volumes\",\"value\":\"/vplex/v2/distributed_storage/distributed_virtual_volumes/${distributed_device}_vol\"}]\'
bodyAddSV=$(echo $bodyAddSVtemp | sed s/\'//g)
#echo "API used: https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/"
curl -k -X PATCH -d $bodyAddSV -H 'Content-Type: application/json' -u $user:$password "https://$VPLEX/vplex/v2/clusters/cluster-1/exports/storage_views/$StorageView" | jq '.'

