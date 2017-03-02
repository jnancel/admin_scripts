#!/usr/bin/env python

import argparse, sys
from pyzabbix import ZabbixAPI
from authentication import authenticate

def removehosts(zapi, node):
  '''
  Get id of host and remove this host
  No return
  '''
  try:
    hostid = zapi.host.get(output="hostid", filter={'name': node})[0]['hostid']
  except:
    print "Node %s not found" % node
    return

  #zapi.host.delete(hosts=[{'hostid': hostid}])
  zapi.host.delete(hostid)

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Remove a Zabbix host'
  )
  parser.add_argument('-n', '--node', help="The node name in Zabbix")
  args = parser.parse_args()

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  
  if not args.node:
    print "No node specified, exiting..."
    parser.print_help()
    sys.exit(2)

  zapi = authenticate() 

  removehosts(zapi, args.node)
