#!/usr/bin/env python

import argparse, sys, yaml
from pyzabbix import ZabbixAPI
from support_functions import *
from addhosttotemplate import addhosttotemplate
from authentication import authenticate

equivalence = {
  'mysql': 'Template App MySQL',
  'apache': 'Template App HTTP Service',
  'ntp': 'Template App NTP Service',
  'monitoring::zabbix_proxy': 'Template App Zabbix Proxy',
}

def updatetemplate(zapi, path):
  '''
  Parse the Puppet class file and add nodes to templates
  No return
  '''
  currentYaml = load_yaml(path)

  for classe in equivalence:
    for node in currentYaml[classe]:
      nodename = node.split('.')[0]
      if nodename == 'all':
        for host in zapi.host.get(output="extend"):
          hostname = host['name']
          addhosttotemplate(zapi, hostname, equivalence[classe])
      else:
        addhosttotemplate(zapi, nodename, equivalence[classe])

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Parse Puppet classes and add host to templates in Zabbix accordingly'
  )
  parser.add_argument('-p', '--path', help="Path to yaml classes file. Default is /etc/puppetlabs/code/classes.yaml")
  args = parser.parse_args()

  if not args.path:
    arg_path = '/etc/puppetlabs/code/classes.yaml'
  else:
    arg_path = args.path
 
  zapi = authenticate()

  updatetemplate(zapi, arg_path)
