# admin_scripts
I have accumulated a few scripts during my time as SysAdmin

Here they are.

## Zabbix

I started using Zabbix instead of Nagios/Shinken because of the auto-registration capability plus the fact that communication stream can go from client ( or proxy ) to servers. I find that stream more useful in lots of cases.

In Zabbix repository are : 

### zabbixapi.conf
A configuration file containing all informations to connect to the Zabbix server.

User must be Zabbix Super Admin

### authentication.py
A python script used to authentice against the Zabbix server using informations in zabbixapi.conf

### addhosttotemplate.py
Add already existing Zabbix host to already existing Zabbix template based on names

### create_graph.py
Create a graph using various one or more items, each one can be attached to left or right Y-axis.

### create_user.py
Create a user belonging to a default group ( for permissions ). 

If using LDAP authentication ( like me ), you have to set a password anyway but it won't be used.

### removehosts.py
Remove a host from Zabbix

### updatetemplatefromclasses.py
Since I'm using Puppet to configure nodes, it can be useful to map Zabbix templates to Puppet classes.

This script is doing just that by mapping Zabbix templates ( identified by names ) to Puppet classes extracted from a yaml file containing all classes and nodes.
You just have to update the `equivalence` dictionnary at the beginning of the file to match your needs.

## Gandi
Simple scripts to communicate with Gandi. Those scripts prerequire that you have gandi cli configured on your station.

### update.sh
Update an IP

### delete.sh
Delete an entry

## Libvirt
I happened to have several dedicated servers running libvirt to administer. Here are some useful scripts in that case.

To execute those, your station needs to have ssh access without password to the hypervisors.

### migrate_vm.sh
Migrate a domain from a libvirt hypervisor to another

### change_mem.sh
Update memory and cpu count of a libvirt domain. May need a reboot of that domain.

Doesn't need to specify the hypervisor name since it uses clush to poll all hypervisors to find the proper one. All your hypervisor needs to be in a group called hypvlibv

## Misc

### generate_random_string.sh
Name speaks for itself :D
