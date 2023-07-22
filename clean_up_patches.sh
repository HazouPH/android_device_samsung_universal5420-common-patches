#!/bin/bash
PATCH_DIR=device/samsung/universal5420-common-patches
cd ../../../
ROOT_DIR=`pwd`
cd ${PATCH_DIR}
projects () {
	LAST_COMMIT=`cat ${proj}/.lastcommit`
	echo ${proj} ${LAST_COMMIT}
	cd ${ROOT_DIR}/${proj}
	git reset --hard $LAST_COMMIT >/dev/null
	git clean -d -f -x
	cd ${ROOT_DIR}/${PATCH_DIR}
	rm ${proj}/.lastcommit
}
	
for proj in `find . -type f -name '*.lastcommit' | sed -r 's|/[^/]+$||' |sort |uniq`
do
	projects ${proj}
done
