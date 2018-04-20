import os
from os.path import join
from sys import argv

fileName = argv[1]
dir = argv[2]

for root, dirs, files in os.walk(dir):
    print("searching"), root
    if fileName in files:
        print "Found %s" % join(root, fileName)
        break