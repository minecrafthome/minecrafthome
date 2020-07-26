import sys
import re


# Specify only these two args to be provided in the daemon options, so no other args are provided
file_1 = sys.argv[0]


# Check if file contains "Done" which is good enough for syntax checking
valid_output = re.search("Done", open(file_1).read())

# Exit correctly
if valid_output:
    sys.exit(0)
else:
    sys.exit(1)