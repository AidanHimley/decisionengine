#!/bin/sh
# util script to clear automatically generated passwords and tokens for debugging
rm persistent-mount/condor/passwords.d/POOL \
    persistent-mount/condor/tokens.d/condor.idtoken \
    2>/dev/null || :