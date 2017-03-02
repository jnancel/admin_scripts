#!/usr/bin/env python

import argparse, sys
from pyzabbix import ZabbixAPI
from authentication import authenticate

class get_color:
  last_id = 0
  colors = ["C04000", "800000", "191970", "3EB489", "FFDB58", "000080",
            "CC7722", "808000", "FF7F00", "002147", "AEC6CF", "836953",
            "CFCFC4", "77DD77", "F49AC2", "FFB347", "FFD1DC", "B39EB5",
            "FF6961", "CB99C9", "FDFD96", "FFE5B4", "D1E231", "8E4585",
            "FF5A36", "701C1C", "FF7518", "69359C", "E30B5D", "826644",
            "FF0000", "414833", "65000B", "002366", "E0115F", "B7410E",
            "FF6700", "F4C430", "FF8C69", "C2B280", "967117", "ECD540",
            "082567"]

  def next(self):
    self.last_id = (self.last_id + 1) % len(self.colors)
    return self.colors[self.last_id]


def get_item_id(nodename, itemname):
  '''
  Get all items on host nodename and then search for
  item called itemname
  Returns an itemid
  '''
  itemsbyhost = zapi.item.get(host = nodename)

  try:
    itemid = [d['itemid'] for d in itemsbyhost if d['name'] == itemname][0]
  except:
    print "Cannot find item %s on host %s. Exiting..." % (itemname, nodename)
    sys.exit(5)

  return itemid

def create_graph(zapi, name, items, height = 200, width = 900):
  '''
  Get itemid, colors and Y-axis reference and creates a graph
  No return
  '''

  gitems = []
  colors = get_color()

  for hostplusitem in items:
    if hostplusitem[2] == 'left':
      yside = 0
    elif hostplusitem[2] == 'right':
      yside = 1

    gitems.append({
      'itemid': get_item_id(hostplusitem[0], hostplusitem[1]), 
      'color': colors.next(),
      'yaxisside': yside
    })

  args = {
    'height': height,
    'width': width,
    'name': name,
    'gitems': gitems
  }

  zapi.graph.create(args)

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description='Create a graph',
    epilog = 'Example : %s -l nodename1 itemname1 -r nodename1 itemname2 -l nodename2 itemname3' % sys.argv[0]
  )
  parser.add_argument('-n', '--name', help="The graph name")
  parser.add_argument('-H', '--height', help="Graph height. Default is 200")
  parser.add_argument('-w', '--width', help="Graph width. Default is 900")
  parser.add_argument('-l', '--leftitems', 
    help="Items to associate to the left Y-axis of the graph. Takes a Zabbix node name and item name. Can be specified multiple times", 
    action='append', nargs=2, metavar=('host', 'item'))
  parser.add_argument('-r', '--rightitems', 
    help="Items to associate to the right Y-axis of the graph. Takes a Zabbix node name and item name. Can be specified multiple times",
    action='append', nargs=2, metavar = ('host', 'item'))
  args = parser.parse_args()

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  
  if not args.name:
    print "No name specified for the graph, exiting..."
    parser.print_help()
    sys.exit(2)
 
  if not args.leftitems and not args.rightitems:
    print "No items specified, exiting..."
    parser.print_help()
    sys.exit(3)

  arg_items = []
  for couple in args.leftitems:
    couple.append('left')
    arg_items.append(couple)
  for couple in args.rightitems:
    couple.append('right')
    arg_items.append(couple)

  zapi = authenticate()

  create_graph(zapi, args.name, arg_items, args.height, args.width)
