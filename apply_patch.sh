#!/bin/bash
CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
MAKE_FLAGS=-j$((CORE_COUNT + 2))

if [ "${ANDROID_BUILD_TOP}" != "" ]
then
	ret=`pwd | grep "${ANDROID_BUILD_TOP}"`
	if [ "$ret" != "" ]
	then
		ROOT_DIR=${ANDROID_BUILD_TOP}
	fi
fi
if [ "$ROOT_DIR" = "" ]
then
	ret=`cat Makefile 2>/dev/null | grep "include build/make/core/main.mk"`
	if [ "$ret" != "" ]
	then
		ROOT_DIR=`pwd`
	else
		echo "Do the source & lunch first or launch this from android build top directory"
	exit
	fi
fi

PATCH_DIR=${ROOT_DIR}/device/samsung/universal5420-common-patches

# Enable the temporary Makefile to abort the build in case of failure
cp ${PATCH_DIR}/Show-stopper.mk ${PATCH_DIR}/Android.mk
FAILED=false

cd ${PATCH_DIR}

projects () {
	ls ${proj}/*.patch 1>/dev/null 2>/dev/null
	if [ $? -eq 0 ]
	then
		echo "Applying patches under ${proj}..."
		if [ -e ${ROOT_DIR}/${proj} ]
		then
			cd ${ROOT_DIR}/${proj}
			# log last commit
			if [ ! -f ${PATCH_DIR}/${proj}/.lastcommit ]
			then
				git rev-parse --short HEAD > ${PATCH_DIR}/${proj}/.lastcommit
			fi
		else
			echo "no source code, skip dir: ${ROOT_DIR}/${proj}"
			break
		fi
		for patch_name in `ls ${PATCH_DIR}/${proj} --ignore-backups --ignore="*.bk"`
		do
			patch=${PATCH_DIR}/${proj}/${patch_name}
			change_id=`grep -w "^Change-Id:" ${patch} | awk '{print $2}'`
			ret=`git --no-pager log --format=format:%H -1 --grep "Change-Id: ${change_id}"`
			if [ -z $ret ]
			then
				echo "Applying ${proj}:${patch_name}"
				git am -k -3 --ignore-space-change --ignore-whitespace ${patch}
			if [ $? -ne 0 ]
			then
					echo "Failed at ${proj}"
					echo "Abort..."
					git am --abort
					FAILED=true
					exit
				fi
			else
				echo "Applied ${proj}:${patch_name}, ignore and continue..."
			fi 
		done
	fi
	cd ${PATCH_DIR}
}

for proj in `find . -type f -name '*.patch' | sed -r 's|/[^/]+$||' |sort |uniq` 
do
	projects ${proj} &
done

wait

# All went well, disable the show-stopper Makefile
if [ "$FAILED" = false ];
then
	(\rm -f ${PATCH_DIR}/Android.mk)
fi
