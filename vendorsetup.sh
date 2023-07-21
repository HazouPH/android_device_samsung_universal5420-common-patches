#!/bin/bash

# This script is source by build/envsetup.sh

    # Patch the tree
    bash device/samsung/universal5420-common-patches/apply_patch.sh
    
    # RE-Execute the contents of any vendorsetup.sh files we can find.
    for f in `test -d device && find device -maxdepth 6 -name 'vendorsetup.sh' 2> /dev/null` \
             `test -d vendor && find vendor -maxdepth 6 -name 'vendorsetup.sh' 2> /dev/null`
    do
        case "$f" in
            device/samsung/universal5420-common-patches/vendorsetup.sh )
            continue
            ;;
        esac
     
        echo "including $f"
        . $f
    done
    unset f
