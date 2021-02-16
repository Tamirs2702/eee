#!/bin/sh
# compress /important to STDOUT, follow symlinks, use absolute paths, hide missing symlinks warnings
exec tar cPzvhf - --warning=no-file-removed /important
