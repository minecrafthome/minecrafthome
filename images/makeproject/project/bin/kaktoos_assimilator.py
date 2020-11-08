#!/usr/bin/env python
from assimilator import *
from Boinc import boinc_project_path, boinc_db
import re, os


re_result = re.compile(r"^s: (\d+),\r?$", re.MULTILINE)
re_name = re.compile(r"_y(\d+)_", re.MULTILINE)
class KaktoosAssimilator(Assimilator):
        def __init__(self):
                Assimilator.__init__(self)

        def assimilate_handler(self, wu, results, canonical_result):
                if canonical_result == None:
                        return
                path = boinc_project_path.project_path("kaktoos_results")
                input_path = self.get_file_path(canonical_result)
                heightmatch = re_name.search(canonical_result.name)
                height = heightmatch.group(1)
                filename = "results_" + height + ".txt"

                with open(input_path) as input_file:
                    input_str = input_file.read()

                try:
                        os.makedirs(path)
                except OSError:
                        pass
                with open(os.path.join(path, filename), "a") as f:
		        for match in re_result.finditer(input_str):
                                f.write("{}\n".format(match.group(1)))

if __name__ == "__main__":
        asm = KaktoosAssimilator()
        asm.run()
