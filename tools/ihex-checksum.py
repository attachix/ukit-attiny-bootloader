#!/bin/python
import sys
import re

if len(sys.argv) < 2:
    print "Usage:\n\t%s <hex-string>" % sys.argv[0]
    sys.exit(1)

hex_string = sys.argv[1]

def sum(val):
    total = 0
    pairs = re.findall('.{2}', val)
    for data in pairs:
        total += int(data, 16)
    return total

sys.stdout.write("%02X" % (((sum(hex_string) ^ 0xFF) + 1) & 0xFF))