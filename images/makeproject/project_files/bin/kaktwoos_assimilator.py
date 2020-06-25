#!/usr/bin/env python
from assimilator import *
import re

re_unit = re.compile(r"--chunkseed (\d+)")
re_result = re.compile(r"^(\d+)$", re.MULTILINE)

class KaktwoosAssimilator(Assimilator):
	def __init__(self):
		Assimilator.__init__(self)

	def assimilate_handler(self, wu, results, canonical_result):
		chunkseed = re_unit.search(wu.xml_doc).group(1)
		with open("results.txt", "a") as f:
			for match in re_result.finditer(canonical_result.stderr_out):
				f.write("{} {}\n".format(chunkseed, match.group(1)))

if __name__ == "__main__":
	asm = KaktwoosAssimilator()
	asm.run()