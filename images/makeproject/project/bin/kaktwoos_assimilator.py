#!/usr/bin/env python
from assimilator import *
from Boinc import boinc_project_path
import re, os

re_unit = re.compile(r"--chunkseed (\d+)")
re_result = re.compile(r"^(\d+)\r?$", re.MULTILINE)
re_name = re.compile(r"_y(\d+)_", re.MULTILINE)

class KaktwoosAssimilator(Assimilator):
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
                chunkseed = re_unit.search(wu.xml_doc).group(1)
                path = boinc_project_path.project_path("kaktwoos_results")
                heightmatch = re_name.search(canonical_result.name)
                height = heightmatch.group(1)
                filename = "results_y" + height + ".txt"
                try:
                    os.makedirs(path)
                except (OSError, IOError) as e:
                    self.logCritical("Unable to create output directory: %s\n", e.filename)
                
                try:
                    with open(os.path.join(path, filename), "a") as f:
                        for match in re_result.finditer(canonical_result.stderr_out):
                            f.write("{} {}\n".format(chunkseed, match.group(1)))
                except (OSError,IOError) as e:
                    self.logCritical("Unable to write to output file: %s\n", e.filename)

if __name__ == "__main__":
        asm = KaktwoosAssimilator()
        asm.run()
