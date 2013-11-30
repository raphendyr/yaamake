#!/usr/bin/env python

import sys, re

pat = re.compile(r'''((?:[^\s"']|"[^"]*"|'[^']*')+)''')
split = lambda x: pat.split(x)[1::2]

col, row, file_ = sys.argv[1:4]

with open(file_, 'r') as h:
    headers = split(h.readline().strip())
    for line in h:
        line = line.strip()
        if line and line[0] != '#':
            fs = dict(zip(headers, split(line)))
            if fs[col] == row:
                for k, v in fs.items():
                    if v and v != '-':
                        print("%s ?= %s" % (k, v.strip("\"'")))
                break
