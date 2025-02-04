#! /bin/sh
#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5. The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the COPYING file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#
srcdir=.
TOP_BUILDDIR=..

# Determine if backward compatibility options enabled
DEPRECATED_SYMBOLS="yes"

EXIT_SUCCESS=0
EXIT_FAILURE=1

nerrors=0
verbose=yes
exit_code=$EXIT_SUCCESS

TEST_NAME=filter_plugin
TEST_BIN=`pwd`/$TEST_NAME
FROM_DIR=`pwd`/.libs
case $(uname) in
    CYGWIN* )
        PLUGINS_FOR_DIR1="$FROM_DIR/cygfilter_plugin1* $FROM_DIR/cygfilter_plugin3*"
        PLUGINS_FOR_DIR2="$FROM_DIR/cygfilter_plugin2* $FROM_DIR/cygfilter_plugin4*"
        ;;
    *)
        PLUGINS_FOR_DIR1="$FROM_DIR/libfilter_plugin1* $FROM_DIR/libfilter_plugin3*"
        PLUGINS_FOR_DIR2="$FROM_DIR/libfilter_plugin2* $FROM_DIR/libfilter_plugin4*"
        ;;
esac
PLUGIN_DIR1=filter_plugin_dir1
PLUGIN_DIR2=filter_plugin_dir2
CP="cp -p"    # Use -p to preserve mode,ownership,timestamps
RM="rm -rf"

# Print a line-line message left justified in a field of 70 characters
# beginning with the word "Testing".
#
TESTING() {
    SPACES="                                                               "
    echo "Testing $* $SPACES" | cut -c1-70 | tr -d '\012'
}

# Main Body
# Create test directories if necessary.
test -d $PLUGIN_DIR1 || mkdir -p $PLUGIN_DIR1
if [ $? != 0 ]; then
    echo "Failed to create filter plugin test directory ($PLUGIN_DIR1)"
    exit $EXIT_FAILURE
fi

test -d $PLUGIN_DIR2 || mkdir -p $PLUGIN_DIR2
if [ $? != 0 ]; then
    echo "Failed to create filter plugin test directory ($PLUGIN_DIR2)"
    exit $EXIT_FAILURE
fi

# Copy plugins for the tests.
$CP $PLUGINS_FOR_DIR1 $PLUGIN_DIR1
if [ $? != 0 ]; then
    echo "Failed to copy filter plugins ($PLUGINS_FOR_DIR1) to test directory."
    exit $EXIT_FAILURE
fi

$CP $PLUGINS_FOR_DIR2 $PLUGIN_DIR2
if [ $? != 0 ]; then
    echo "Failed to copy filter plugins ($PLUGINS_FOR_DIR2) to test directory."
    exit $EXIT_FAILURE
fi

# setup plugin path
ENVCMD="env HDF5_PLUGIN_PATH=${PLUGIN_DIR1}:${PLUGIN_DIR2}"

# Run the test
$ENVCMD $TEST_BIN
if [ $? != 0 ]; then
    nerrors=`expr $nerrors + 1`
fi

############################################
# HDFFV-9655 test for relative path disabled
# setup filter plugin path relative to test
# actual executable is in the .libs folder
#ENVCMD="env HDF5_PLUGIN_PATH=@/../${PLUGIN_DIR1}:@/../${PLUGIN_DIR2}"
#
# Run the test
#$ENVCMD $TEST_BIN
#if [ $? != 0 ]; then
#    nerrors=`expr $nerrors + 1`
#fi
#############################################

# print results
if test $nerrors -ne 0 ; then
    echo "$nerrors errors encountered"
    exit_code=$EXIT_FAILURE
else
    echo "All filter plugin tests passed."
    exit_code=$EXIT_SUCCESS
fi

# Clean up temporary files/directories and leave
$RM $PLUGIN_DIR1 $PLUGIN_DIR2

exit $exit_code
