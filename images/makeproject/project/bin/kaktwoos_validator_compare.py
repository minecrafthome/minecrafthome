import sys
import re
import hashlib


# Specify only these two args to be provided in the daemon options, so no other args are provided
file_1 = sys.argv[0]
file_2 = sys.argv[1]


# Strip the files of unneeded information (checkpoints, workunit) by extracting seed, height data
seeds_1 = re.findall("Found seed: ([\s\S]*?)\n", open(file_1).read())
seeds_2 = re.findall("Found seed: ([\s\S]*?)\n", open(file_2).read())

# Remove duplicates (checkpoints can cause these)
seeds_1 = list(set(seeds_1))
seeds_2 = list(set(seeds_2))

# Exit correctly
if seeds_1 == seeds_2:
    sys.exit(0)
else:
    sys.exit(1)