#!/usr/bin/env python
from assimilator import *
from Boinc import boinc_project_path, boinc_db, sched_messages
import re, os


re_result = re.compile(r"^s: (\d+),\r?$", re.MULTILINE)
re_name = re.compile(r"_y(\d+)_", re.MULTILINE)
class KaktoosAssimilator(Assimilator):
        def __init__(self):
                Assimilator.__init__(self)
        def _writeLog(self, mode, *args):
            """
            A private helper function for writeing to the log
            """
            self.log.printf(mode, *args)
        
        def logCritical(self, *messageArgs):
            """
            A helper function for logging critical messages
            """
            self._writeLog(sched_messages.CRITICAL, *messageArgs)
    
        def logNormal(self, *messageArgs):
            """
            A helper function for logging normal messages
            """
            self._writeLog(sched_messages.NORMAL, *messageArgs)
    
        def logDebug(self, *messageArgs):
            """
            A helper function for logging debug messages
            """
            self._writeLog(sched_messages.DEBUG, *messageArgs)
        def assimilate_handler(self, wu, results, canonical_result):
                if canonical_result == None:
                        return
                path = boinc_project_path.project_path("kaktoos_results")
                input_path = self.get_file_path(canonical_result)
                heightmatch = re_name.search(canonical_result.name)
                height = heightmatch.group(1)
                filename = "results_" + height + ".txt"
                input_str = ""
                try:
                    with open(input_path) as input_file:
                        input_str = input_file.read()
                except (OSError,IOError) as e:
                    self.logCritical("Unable to open input file: %s\n", e.filename)

                try:
                    os.makedirs(path)
                except (OSError,IOError) as e:
                    self.logCritical("Unable to create output directory: %s\n", e.filename)

                try:
                    with open(os.path.join(path, filename), "a") as f:
                        for match in re_result.finditer(input_str):
                            f.write("{}\n".format(match.group(1)))
                except (OSError,IOError) as e:
                    self.logCritical("Unable to write to output file: %s\n", e.filename)
if __name__ == "__main__":
        asm = KaktoosAssimilator()
        asm.run()