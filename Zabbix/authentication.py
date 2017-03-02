#!/usr/bin/env python

import ConfigParser, sys
from pyzabbix import ZabbixAPI

def authenticate( conffile = '/path/to/file/zabbixapi.conf'):
  '''
  Central authentication for Zabbix
  '''

  configParser = ConfigParser.RawConfigParser()
  configFilePath = r'%s' % conffile
  configParser.read(configFilePath)

  url = configParser.get('monitoring', 'url')
  protocol = configParser.get('monitoring', 'protocol')
  user = configParser.get('monitoring', 'user')
  password = configParser.get('monitoring', 'password')

  zapi = ZabbixAPI("%s://%s" % (protocol, url))
  zapi.login(user, password)

  return zapi
