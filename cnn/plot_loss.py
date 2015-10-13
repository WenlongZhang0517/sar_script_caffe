#!/usr/bin/env python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

import os
import sys

lines = open('log.txt').readlines()
lines = [l.strip().split() for l in lines if l.find(' loss = ') != -1]
loss = [l[-1] for l in lines[4:]]
it = [l[-4].strip(',') for l in lines[4:]]
loss = np.asarray(loss).astype(float);
it = np.asarray(it).astype(int);
plt.plot(it,loss)
plt.show()
