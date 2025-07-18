#!/bin/bash

if [[ $CCACHE == 1 ]] ; then
    echo "* ccache is enabled"
    export path PATH=/usr/lib/ccache:${PATH}
    ccache -M 0			# No size limit
    ccache -Ccz			# Clean up the cache and stats
else
    if [[ ${SANITY_CHECK} == 1 ]] ; then
	echo "CCACHE=1 is needed with SANITY_CHECK=1"
	exit 1
    fi
fi

SRC=$(realpath ${1})
VER=${2}
OUT=${3}

mkdir -p ${OUT}
OUT=$(realpath ${3})
input=$(realpath ${4}) # 500

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
cat ${input} | while read -r line ; do
	lineno=$(echo ${line} | cut -d ' ' -f1)
	commit=$(echo ${line} | cut -d ' ' -f2)
	git checkout ${commit}
	make defconfig
	if [[ ${bin} == "busybox" ]] ; then
	    sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/g' .config
	fi
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

if [[ ${SANITY_CHECK} == 1 ]] ; then
    git checkout ${VER}
    cat ${input} | while read -r line ; do
	    lineno=$(echo ${line} | cut -d ' ' -f1)
	    commit=$(echo ${line} | cut -d ' ' -f2)
	    git checkout ${commit}
	    make defconfig
	    if [[ ${bin} == "busybox" ]] ; then
		sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/g' .config
	    fi
	    path=${OUT}/${lineno}
	    time=${path}.time.2
	    stdout=${path}.stdout.2
	    stderr=${path}.stderr.2
	    exstat=${path}.exitstatus.2
	    binary=${path}.bin.2
	    ${env} /usr/bin/time -pq -o ${time} make -j $nproc 1>${stdout} 2>${stderr}
	    echo $? > ${exstat}
	    if [ -f ${bin} ] ; then
		cp ${bin} ${binary}
	    fi
	    if [[ $CCACHE == 1 ]] ; then
		ccache -svv > ${path}.ccache-stats.2
	    fi
	    git clean -dfx
	done
fi


popd
