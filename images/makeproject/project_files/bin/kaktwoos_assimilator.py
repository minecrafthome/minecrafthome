#!/usr/bin/env python
from assimilator import *
from Boinc import boinc_project_path
import re, os

re_unit = re.compile(r"--chunkseed (\d+)")
re_result = re.compile(r"^(\d+)\r?$", re.MULTILINE)

class KaktwoosAssimilator(Assimilator):
	def __init__(self):
		Assimilator.__init__(self)

	def assimilate_handler(self, wu, results, canonical_result):
		chunkseed = re_unit.search(wu.xml_doc).group(1)
		path = boinc_project_path.project_path("kaktwoos_results")
		try:
			os.makedirs(path)
		except OSError:
			pass
		with open(os.path.join(path, "results.txt"), "a") as f:
			for match in re_result.finditer(canonical_result.stderr_out):
				f.write("{} {}\n".format(chunkseed, match.group(1)))

if __name__ == "__main__":
	asm = KaktwoosAssimilator()
	asm.run()