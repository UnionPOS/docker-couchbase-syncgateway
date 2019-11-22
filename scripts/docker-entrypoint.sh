#!/bin/bash
set -e

DIR=/docker-entrypoint.d
# is scripts exist in DIR run them
if [[ -d "$DIR" ]]
then
  /bin/run-parts --verbose "$DIR"
fi

LOGFILE_DIR=/var/log/sync_gateway
mkdir -p $LOGFILE_DIR

LOGFILE_ACCESS=$LOGFILE_DIR/sync_gateway_access.log
LOGFILE_ERROR=$LOGFILE_DIR/sync_gateway_error.log

# Run SG and use tee to append stdout and stderr to separate logfiles
# Process substitution described here: https://stackoverflow.com/a/692407
exec sync_gateway "$@" > >(tee -a $LOGFILE_ACCESS) 2> >(tee -a $LOGFILE_ERROR >&2)
