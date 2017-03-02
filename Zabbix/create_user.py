#!/usr/bin/env python

import argparse, sys
from pyzabbix import ZabbixAPI
from authentication import authenticate

def create_user(zapi, username):
  '''
  Creates a new user
  No return
  '''

  # Default group is "ro on all" on Zabbix
  # This is to create read-only users

  # Looking for the default group
  default_group = 'ro on all'
  
  args = {
    'with_gui_access': 0
  }

  usergroups = zapi.usergroup.get(args)
  for usergroup in usergroups:
    if usergroup['name'] == default_group:
      groupid = usergroup['usrgrpid']
      break

  args = {
    'alias': username,
    'passwd': 'mypassword',
    'usrgrps': [
      {
        'usrgrpid': groupid,
      }
    ],
    'user_medias': [
      {
        'mediatypeid': 1,
        'sendto': "%s@example.com" % username,
        'active': 0,
        'severity': 63,
        'period': '1-7,00:00-24:00'
      }
    ]
  }

  print args

  zapi.user.create(args)

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Create an item'
  )
  parser.add_argument('-n', '--name', help="The username to create. Mandatory")
  args = parser.parse_args()

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  
  if not args.name:
    print "No username specified, exiting..."
    parser.print_help()
    sys.exit(2)
 
  zapi = authenticate()

  create_user(zapi, args.name)
