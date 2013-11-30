#!/usr/bin/env python

import sys, re

pat = re.compile(r'''((?:[^\s"']|"[^"]*"|'[^']*')+)''')
split = lambda x: pat.split(x)[1::2]

col1, col2, file_ = sys.argv[1:4]
vals = []

with open(file_, 'r') as h:
    headers = split(h.readline().strip())
    for line in h:
        line = line.strip()
        if line and line[0] != '#':
            fs = dict(zip(headers, split(line)))
            vals.append((fs[col1], fs[col2]))

w = max([len(c1) for c1, c2 in vals])
fmt = "  %%-%ds - %%s" % (w,)

for c1, c2 in vals:
    print(fmt % (c1, c2.strip("\"'")))
