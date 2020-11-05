Ansible modules for PowerStore and VPLEX - beta version

all files under root folder are for PowerStore
all files under vplex folder are for VPLEX

Prereqs:
- ansible must be installed
- "jq" (JSON processor) must be installed (for the VPLEX module) - see https://stedolan.github.io/jq/
- update PowerStore IP addresses and credentials in PowerStore-site1.yml and PowerStore-site2.yml (assuming both have same credentials)
- update VPLEX IP address and credentials in ./vplex/vplex_provisioning/host_vars/ansible.yaml 
- update PowerStore Serial Numbers in ./vplex/vplex_provisioning/host_vars/ansible.yaml (for the rediscover arrays)
- update all other Inputs for extent/device/volume names + StorageView in ./vplex/vplex_provisioning/host_vars/ansible.yaml
- update ./vplex/vplex_provisioning/tasks/create_dd.sh to your needs (this part was not yet ready in Ansible, so we ran a few REST API calls to create the distributed volume, add it to a CG and export it to a Host
- there should not be any unclaimed volume on both VPLEX before running the master playbook (current module will claim all available volumes)

How to run the master playbook ?
ansible-playbook master_playbook.yaml 


master_playbook.yaml : combined playbook for both PowerStore and VPLEX ; creates a volume on both PowerStore Site1 and Site2, then present each volume to their local VPLEX, then encapsulate the volume into VPLEX and creates a distributed volume. Finally the VPLEX distributed volume is added to Consistency Group "DistCG1" and exported to Host on VPLEX cluster-1.

