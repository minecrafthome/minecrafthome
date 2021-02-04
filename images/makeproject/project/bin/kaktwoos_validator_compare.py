#!/usr/bin/env python

import sys
import re
import boinc_path_config
from Boinc import database

# argv[1] and argv[2] contain the file we want to check
result_1 = sys.argv[1]
result_2 = sys.argv[2]
print result_1
print result_2
database.connect_default_config()
file_1 = database.Results.find(id=result_1)[0]
file_2 = database.Results.find(id=result_2)[0]


print("{}".format(file_1))
print("{}".format(file_2))
# Strip the files of unneeded information (checkpoints, workunit) by extracting seed
seeds_1 = re.findall("Found seed: ([\s\S]*?)(?:\n|\r\n)", file_1.stderr_out)
seeds_2 = re.findall("Found seed: ([\s\S]*?)(?:\n|\r\n)", file_2.stderr_out)

# Remove duplicates (checkpoints can cause these) and sort the lists
seeds_1 = sorted(list(set(seeds_1)))
seeds_2 = sorted(list(set(seeds_2)))

# Exit correctly
if seeds_1 == seeds_2:
    sys.exit(0)
else:
    sys.exit(1)
