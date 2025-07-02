#!/bin/bash

SRC=$(realpath ${1})
VER=${2}
OUT=${3}

if [[ $CCACHE == 1 ]] ; then
    echo "* ccache is enabled"
    export path PATH=/usr/lib/ccache:${PATH}
    ccache -M 0			# No size limit
    ccache -Ccz			# Clean up the cache and stats
fi


mkdir -p ${OUT}
OUT=$(realpath ${3})
size=${4} # 500

if [[ ${SRC} == *linux* ]] ; then
    bin="vmlinux"
    export KBUILD_BUILD_TIMESTAMP="Sun Jan 1 01:00:00 UTC 2023"
    export KBUILD_BUILD_USER="user"
    export KBUILD_BUILD_HOST="host"
    export KBUILD_BUILD_VERSION="1"
elif [[ ${SRC} == *toybox* ]] ; then
    bin="toybox"
elif [[ ${SRC} == *busybox* ]] ; then
    bin="busybox"
    export KCONFIG_NOTIMESTAMP=1
fi

pushd ${SRC}
git config --global --add safe.directory $(pwd)
git checkout ${VER}
paste -d ' ' <(seq -w ${size}) <(git rev-list --max-count=${size} HEAD | tac) | \
    while read -r line ; do
	lineno=$(echo ${line} | cut -d ' ' -f1)
	commit=$(echo ${line} | cut -d ' ' -f2)
	git checkout ${commit}
	make defconfig
	path=${OUT}/${lineno}
	time=${path}.time
	stdout=${path}.stdout
	stderr=${path}.stderr
	exstat=${path}.exitstatus
	binary=${path}.bin
	${env} /usr/bin/time -pq -o ${time} make -j $nproc 1>${stdout} 2>${stderr}
	echo $? > ${exstat}
	if [ -f ${bin} ] ; then
	    cp ${bin} ${binary}
	fi
	if [[ $CCACHE == 1 ]] ; then
	    ccache -svv > ${path}.ccache-stats
	fi
	git clean -dfx
    done
popd
