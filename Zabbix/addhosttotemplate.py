#!/usr/bin/env python

import argparse, sys
from pyzabbix import ZabbixAPI
from authentication import authenticate

def addhosttotemplate(zapi, node, template):
  '''
  Get id of host and template and add first to second
  No return
  '''
  try:
    hostid = zapi.host.get(output="hostid", filter={'name': node})[0]['hostid']
  except:
    print "Node %s not found" % node
    return

  try: 
    templateid = zapi.template.get(output="templateid", filter={'name': template})[0]['templateid']
  except:
    print "Template %s not found" % template
    return
  
  zapi.template.massadd(templates=[{'templateid': templateid}], hosts=[{'hostid': hostid}])

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Add a Zabbix host to a Zabbix template. Both have to already exist'
  )
  parser.add_argument('-n', '--node', help="The node name in Zabbix")
  parser.add_argument('-t', '--template', help="The template name in Zabbix")
  args = parser.parse_args()

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  
  if not args.node:
    print "No node specified, exiting..."
    parser.print_help()
    sys.exit(2)
 
  if not args.template:
    print "No template specified, exiting..."
    parser.print_help()
    sys.exit(3)

  zapi = authenticate()

  addhosttotemplate(zapi, args.node, args.template) 
