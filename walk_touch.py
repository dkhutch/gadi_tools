#!/usr/bin/env python

import os

for root, dirs, files in os.walk("."):
	for name in files:
		fname = os.path.join(root,name)
		cmd = 'touch -a %s' % fname
		os.system(cmd)

		