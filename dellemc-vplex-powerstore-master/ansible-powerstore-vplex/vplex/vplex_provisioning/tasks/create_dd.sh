#!/bin/bash

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -i|--ip)
    VPLEX_IP="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--user)
    VPLEX_USER="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    VPLEX_PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    -cg|--cg)
    VPLEX_CG="$2"
    shift # past argument
    shift # past value
    ;;
    -stv|--storageview)
    STORAGE_VIEW="$2"
    shift # past argument
    shift # past value
    ;;
    -dd|--distributeddevice)
    DISTRIBUTED_DEVICE="$2"
    shift # past argument
    shift # past value
    ;;
    -d1|--deviceclusterleg1)
    DEVICE_CLUSTER_LEG_1="$2"
    shift # past argument
    shift # past value
    ;;
    -d2|--deviceclusterleg2)
    DEVICE_CLUSTER_LEG_2="$2"
    shift # past argument
    shift # past value
    ;;
    #--default)
    #DEFAULT=YES
    #shift # past argument
    #;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

#VPLEX_IP=172.16.1.100
#user=ansible
#password=Password123
#CG=DistCG1
#StorageView=vcunity02_idm
#distributed_device=device_Ansible_dd
#this should match variable "create_device_name" in host_vars/ansible.yaml, but suffix is added by some python code..
#device_cluster1_leg1=Ansible_device_VPLEX_2GB_leg1_1
#this should match variable "create_device_name2" in host_vars/ansible.yaml, but suffix is added by some python code..
#device_cluster2_leg2=Ansible_device_VPLEX_2GB_leg2_1

#Creates a distributed device
bodyDDtemp=\'{\"name\":\"${DISTRIBUTED_DEVICE}\",\"primary_leg\":\"/vplex/v2/clusters/cluster-1/devices/$DEVICE_CLUSTER_LEG_1\",\"secondary_leg\":\"/vplex/v2/clusters/cluster-2/devices/$DEVICE_CLUSTER_LEG_2\",\"rule_set\":null,\"sync\":false}\'
bodyDD=$(echo $bodyDDtemp | sed s/\'//g)
echo "API used: https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_devices/"
curl -k -X POST -d $bodyDD -H 'Content-Type: application/json' -u $VPLEX_USER:$VPLEX_PASSWORD "https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_devices/" | jq '.'

#Creates a distributed volume (for future host export)
bodyDVtemp=\'{\"tier\":null,\"thin\":false,\"init\":false,\"device\":\"/vplex/v2/distributed_storage/distributed_devices/$DISTRIBUTED_DEVICE\"}\'
bodyDV=$(echo $bodyDVtemp | sed s/\'//g)
#echo "API used: https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_virtual_volumes/"
curl -k -X POST -d $bodyDV -H 'Content-Type: application/json' -u $VPLEX_USER:$VPLEX_PASSWORD "https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_virtual_volumes/" | jq '.'

#Adds the distributed volume to the distributed Consistency Group "CG"
bodyCGtemp=\'[{\"op\":\"add\",\"path\":\"/virtual_volumes\",\"value\":\"/vplex/v2/distributed_storage/distributed_virtual_volumes/${DISTRIBUTED_DEVICE}_vol\"}]\'
bodyCG=$(echo $bodyCGtemp | sed s/\'//g)
#echo "API used: https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_consistency_groups/Distributed_CG/"
curl -k -X PATCH -d $bodyCG -H 'Content-Type: application/json' -u $VPLEX_USER:$VPLEX_PASSWORD "https://$VPLEX_IP/vplex/v2/distributed_storage/distributed_consistency_groups/$VPLEX_CG/" | jq '.'

#Adds the distributed volume to the Storage View on cluster-1 "StorageView"
bodyAddSVtemp=\'[{\"op\":\"add\",\"path\":\"/virtual_volumes\",\"value\":\"/vplex/v2/distributed_storage/distributed_virtual_volumes/${DISTRIBUTED_DEVICE}_vol\"}]\'
bodyAddSV=$(echo $bodyAddSVtemp | sed s/\'//g)
#echo "API used: https://$VPLEX_IP/vplex/v2/clusters/cluster-1/exports/storage_views/"
curl -k -X PATCH -d $bodyAddSV -H 'Content-Type: application/json' -u $VPLEX_USER:$VPLEX_PASSWORD "https://$VPLEX_IP/vplex/v2/clusters/cluster-1/exports/storage_views/$STORAGE_VIEW" | jq '.'

