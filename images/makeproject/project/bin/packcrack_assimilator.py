#!/usr/bin/env python
from assimilator import *
from Boinc import boinc_project_path
import re, os


re_result = re.compile(r"^(\d+)\r?$", re.MULTILINE)

class PackCrackAssimilator(Assimilator):
        def __init__(self):
                Assimilator.__init__(self)

        def assimilate_handler(self, wu, results, canonical_result):
                if canonical_result == None:
                        return
                path = boinc_project_path.project_path("packcrack_results")
                input_path = self.get_file_path(canonical_result)

                with open(input_path) as input_file:
                    input_str = input_file.read()

                try:
                        os.makedirs(path)
                except OSError:
                        pass
                with open(os.path.join(path, "results.txt"), "a") as f:
		        for match in re_result.finditer(input_str):
                                f.write("{}\n".format(match.group(1)))

if __name__ == "__main__":
        asm = PackCrackAssimilator()
        asm.run()
