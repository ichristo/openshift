#ansible-playbook -i "localhost," -c local get_ravello_ips.yml # connection now local defined in the playbook
ansible-playbook -i "localhost," get_ravello_ips.yml

if [ "$1" != "update" ]
then
    ansible-playbook -i hosts ose_ddns.yml
else
    ansible-playbook -i hosts ose_ddns.yml --tags "update_dns"
fi 
