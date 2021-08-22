#!/usr/bin/env python
import sys
import re

# argv[1] and argv[2] contain the file we want to check
file_1 = sys.argv[1]
file_2 = sys.argv[2]

seeds_1 = open(file_1).read()
seeds_2 = open(file_2).read()

# Remove duplicates (checkpoints can cause these) and sort the lists
seeds_1 = sorted(list(set(seeds_1.splitlines())))
seeds_2 = sorted(list(set(seeds_2.splitlines())))

# Exit correctly
if seeds_1 == seeds_2:
    sys.exit(0)
else:
    sys.exit(1)