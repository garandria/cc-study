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

toybox_randconfig ()
{
    make randconfig
    cat .config						\
	| grep -v CONFIG_TOYBOX_ON_ANDROID		\
	| grep -v CONFIG_TOYBOX_SMACK			\
	| grep -v CONFIG_ARP				\
	| grep -v CONFIG_ARPING				\
	| grep -v CONFIG_BC				\
	| grep -v CONFIG_BOOTCHARTD			\
	| grep -v CONFIG_BRCTL				\
	| grep -v CONFIG_CHSH				\
	| grep -v CONFIG_CROND				\
	| grep -v CONFIG_CRONTAB			\
	| grep -v CONFIG_CSPLIT				\
	| grep -v CONFIG_DHCP				\
	| grep -v CONFIG_DHCP6				\
	| grep -v CONFIG_DHCPD				\
	| grep -v CONFIG_DEBUG_DHCP			\
	| grep -v CONFIG_DIFF				\
	| grep -v CONFIG_DUMPLEASES			\
	| grep -v CONFIG_EXPR				\
	| grep -v CONFIG_FDISK				\
	| grep -v CONFIG_FSCK				\
	| grep -v CONFIG_GETFATTR			\
	| grep -v CONFIG_GETTY				\
	| grep -v CONFIG_GITCOMPAT			\
	| grep -v CONFIG_GITCLONE			\
	| grep -v CONFIG_GITINIT			\
	| grep -v CONFIG_GITREMOTE			\
	| grep -v CONFIG_GITFETCH			\
	| grep -v CONFIG_GITCHECKOUT			\
	| grep -v CONFIG_GROUPADD			\
	| grep -v CONFIG_GROUPDEL			\
	| grep -v CONFIG_HEXDUMP			\
	| grep -v CONFIG_HD				\
	| grep -v CONFIG_INIT				\
	| grep -v CONFIG_IP				\
	| grep -v CONFIG_IPCRM				\
	| grep -v CONFIG_IPCS				\
	| grep -v CONFIG_KLOGD				\
	| grep -v CONFIG_KLOGD_SOURCE_RING_BUFFER	\
	| grep -v CONFIG_LAST				\
	| grep -v CONFIG_LSOF				\
	| grep -v CONFIG_MAN				\
	| grep -v CONFIG_MDEV				\
	| grep -v CONFIG_MDEV_CONF			\
	| grep -v CONFIG_MKE2FS				\
	| grep -v CONFIG_MKE2FS_JOURNAL			\
	| grep -v CONFIG_MKE2FS_GEN			\
	| grep -v CONFIG_MKE2FS_LABEL			\
	| grep -v CONFIG_MKE2FS_EXTENDED		\
	| grep -v CONFIG_MODPROBE			\
	| grep -v CONFIG_MORE				\
	| grep -v CONFIG_ROUTE				\
	| grep -v CONFIG_SH				\
	| grep -v CONFIG_CD				\
	| grep -v CONFIG_DECLARE			\
	| grep -v CONFIG_EXIT				\
	| grep -v CONFIG_SET				\
	| grep -v CONFIG_UNSET				\
	| grep -v CONFIG_EVAL				\
	| grep -v CONFIG_EXEC				\
	| grep -v CONFIG_EXPORT				\
	| grep -v CONFIG_JOBS				\
	| grep -v CONFIG_LOCAL				\
	| grep -v CONFIG_SHIFT				\
	| grep -v CONFIG_SOURCE				\
	| grep -v CONFIG_WAIT				\
	| grep -v CONFIG_WGET				\
	| grep -v CONFIG_STRACE				\
	| grep -v CONFIG_STTY				\
	| grep -v CONFIG_SULOGIN			\
	| grep -v CONFIG_SYSLOGD			\
	| grep -v CONFIG_TCPSVD				\
	| grep -v CONFIG_TELNET				\
	| grep -v CONFIG_TELNETD			\
	| grep -v CONFIG_TFTP				\
	| grep -v CONFIG_TFTPD				\
	| grep -v CONFIG_TR				\
	| grep -v CONFIG_TRACEROUTE			\
	| grep -v CONFIG_USERADD			\
	| grep -v CONFIG_USERDEL			\
	| grep -v CONFIG_VI				\
	| grep -v CONFIG_XZCAT				\
	       >> .config.new
    mv .config.new .config

    echo '# CONFIG_TOYBOX_ON_ANDROID is not set' >> .config
    echo '# CONFIG_TOYBOX_SMACK is not set' >> .config
    echo '# CONFIG_ARP is not set' >> .config
    echo '# CONFIG_ARPING is not set' >> .config
    echo '# CONFIG_BC is not set' >> .config
    echo '# CONFIG_BOOTCHARTD is not set' >> .config
    echo '# CONFIG_BRCTL is not set' >> .config
    echo '# CONFIG_CHSH is not set' >> .config
    echo '# CONFIG_CROND is not set' >> .config
    echo '# CONFIG_CRONTAB is not set' >> .config
    echo '# CONFIG_CSPLIT is not set' >> .config
    echo '# CONFIG_DHCP is not set' >> .config
    echo '# CONFIG_DHCP6 is not set' >> .config
    echo '# CONFIG_DHCPD is not set' >> .config
    echo '# CONFIG_DEBUG_DHCP is not set' >> .config
    echo '# CONFIG_DIFF is not set' >> .config
    echo '# CONFIG_DUMPLEASES is not set' >> .config
    echo '# CONFIG_EXPR is not set' >> .config
    echo '# CONFIG_FDISK is not set' >> .config
    echo '# CONFIG_FSCK is not set' >> .config
    echo '# CONFIG_GETFATTR is not set' >> .config
    echo '# CONFIG_GETTY is not set' >> .config
    echo '# CONFIG_GITCOMPAT is not set' >> .config
    echo '# CONFIG_GITCLONE is not set' >> .config
    echo '# CONFIG_GITINIT is not set' >> .config
    echo '# CONFIG_GITREMOTE is not set' >> .config
    echo '# CONFIG_GITFETCH is not set' >> .config
    echo '# CONFIG_GITCHECKOUT is not set' >> .config
    echo '# CONFIG_GROUPADD is not set' >> .config
    echo '# CONFIG_GROUPDEL is not set' >> .config
    echo '# CONFIG_HEXDUMP is not set' >> .config
    echo '# CONFIG_HD is not set' >> .config
    echo '# CONFIG_INIT is not set' >> .config
    echo '# CONFIG_IP is not set' >> .config
    echo '# CONFIG_IPCRM is not set' >> .config
    echo '# CONFIG_IPCS is not set' >> .config
    echo '# CONFIG_KLOGD is not set' >> .config
    echo '# CONFIG_KLOGD_SOURCE_RING_BUFFER is not set' >> .config
    echo '# CONFIG_LAST is not set' >> .config
    echo '# CONFIG_LSOF is not set' >> .config
    echo '# CONFIG_MAN is not set' >> .config
    echo '# CONFIG_MDEV is not set' >> .config
    echo '# CONFIG_MDEV_CONF is not set' >> .config
    echo '# CONFIG_MKE2FS is not set' >> .config
    echo '# CONFIG_MKE2FS_JOURNAL is not set' >> .config
    echo '# CONFIG_MKE2FS_GEN is not set' >> .config
    echo '# CONFIG_MKE2FS_LABEL is not set' >> .config
    echo '# CONFIG_MKE2FS_EXTENDED is not set' >> .config
    echo '# CONFIG_MODPROBE is not set' >> .config
    echo '# CONFIG_MORE is not set' >> .config
    echo '# CONFIG_ROUTE is not set' >> .config
    echo '# CONFIG_SH is not set' >> .config
    echo '# CONFIG_CD is not set' >> .config
    echo '# CONFIG_DECLARE is not set' >> .config
    echo '# CONFIG_EXIT is not set' >> .config
    echo '# CONFIG_SET is not set' >> .config
    echo '# CONFIG_UNSET is not set' >> .config
    echo '# CONFIG_EVAL is not set' >> .config
    echo '# CONFIG_EXEC is not set' >> .config
    echo '# CONFIG_EXPORT is not set' >> .config
    echo '# CONFIG_JOBS is not set' >> .config
    echo '# CONFIG_LOCAL is not set' >> .config
    echo '# CONFIG_SHIFT is not set' >> .config
    echo '# CONFIG_SOURCE is not set' >> .config
    echo '# CONFIG_WAIT is not set' >> .config
    echo '# CONFIG_STRACE is not set' >> .config
    echo '# CONFIG_STTY is not set' >> .config
    echo '# CONFIG_SULOGIN is not set' >> .config
    echo '# CONFIG_SYSLOGD is not set' >> .config
    echo '# CONFIG_TCPSVD is not set' >> .config
    echo '# CONFIG_TELNET is not set' >> .config
    echo '# CONFIG_TELNETD is not set' >> .config
    echo '# CONFIG_TFTP is not set' >> .config
    echo '# CONFIG_TFTPD is not set' >> .config
    echo '# CONFIG_TR is not set' >> .config
    echo '# CONFIG_TRACEROUTE is not set' >> .config
    echo '# CONFIG_USERADD is not set' >> .config
    echo '# CONFIG_USERDEL is not set' >> .config
    echo '# CONFIG_VI is not set' >> .config
    echo '# CONFIG_XZCAT is not set' >> .config
    echo '# CONFIG_WGET is not set' >> .config

    yes "" | make oldconfig
}

# --------------------------------------------------------------------------
# The code in `busybox_randconfig()` is a part of Busybox's scripts/randomtest
# script. https://git.busybox.net/busybox/tree/scripts/randomtest?h=1_36_stable
# We isolated the part for GLIBC for our use-case

busybox_randconfig ()
{
    # Generate random config
    make randconfig >/dev/null || { echo "randconfig error"; exit 1; }

    # Tweak resulting config
    cat .config \
        | grep -v CONFIG_DEBUG_PESSIMIZE \
        | grep -v CONFIG_WERROR \
        | grep -v CONFIG_CROSS_COMPILER_PREFIX \
        | grep -v CONFIG_SELINUX \
        | grep -v CONFIG_EFENCE \
        | grep -v CONFIG_DMALLOC \
               \
        | grep -v CONFIG_RFKILL \
               >.config.new
    mv .config.new .config
    echo '# CONFIG_DEBUG_PESSIMIZE is not set' >>.config
    echo '# CONFIG_WERROR is not set' >>.config
    echo "CONFIG_CROSS_COMPILER_PREFIX=\"${CROSS_COMPILER_PREFIX}\"" >>.config
    echo '# CONFIG_SELINUX is not set' >>.config
    echo '# CONFIG_EFENCE is not set' >>.config
    echo '# CONFIG_DMALLOC is not set' >>.config
    echo '# CONFIG_RFKILL is not set' >>.config

    # If glibc, don't build static
	cat .config \
	    | grep -v CONFIG_STATIC \
	    | grep -v CONFIG_FEATURE_LIBBUSYBOX_STATIC \
	           \
	    | grep -v CONFIG_FEATURE_2_4_MODULES \
	    | grep -v CONFIG_FEATURE_USE_BSS_TAIL \
	    | grep -v CONFIG_DEBUG_SANITIZE \
	    | grep -v CONFIG_FEATURE_MOUNT_NFS \
	    | grep -v CONFIG_FEATURE_INETD_RPC \
	           >.config.new
	mv .config.new .config
	echo '# CONFIG_STATIC is not set' >>.config
	echo '# CONFIG_FEATURE_LIBBUSYBOX_STATIC is not set' >>.config
	# newer glibc (at least 2.23) no longer supply query_module() ABI.
	# People who target 2.4 kernels would likely use older glibc (and older bbox).
	echo '# CONFIG_FEATURE_2_4_MODULES is not set' >>.config
	echo '# CONFIG_FEATURE_USE_BSS_TAIL is not set' >>.config
	echo '# CONFIG_DEBUG_SANITIZE is not set' >>.config
	# 2018: current glibc versions no longer include rpc/rpc.h
	echo '# CONFIG_FEATURE_MOUNT_NFS is not set' >>.config
	echo '# CONFIG_FEATURE_INETD_RPC is not set' >>.config

    # If STATIC, remove some things.
    # PAM with static linking is probably pointless
    # (but I need to try - now I don't have libpam.a on my system, only libpam.so)
    if grep -q "^CONFIG_STATIC=y" .config; then
	    cat .config \
	        | grep -v CONFIG_PAM \
	               >.config.new
	    mv .config.new .config
	    echo '# CONFIG_PAM is not set' >>.config
    fi

    # Regenerate .config with default answers for yanked-off options
    # (most of default answers are "no").
    { yes "" | make oldconfig >/dev/null; } || { echo "oldconfig error"; exit 1; }
}



pushd ${SRC}
git config --global --add safe.directory $(pwd)
git checkout ${VER}
for i in $(seq -w ${size}) ; do
    if [[ ${bin} == "vmlinux" ]] ; then
	linux_randconfig
    elif [[ ${bin} == "toybox" ]] ; then
	toybox_randconfig
    elif [[ ${bin} == "busybox" ]] ; then
	busybox_randconfig
	sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/g' .config
    fi
    path=${OUT}/${i}
    time=${path}.time
    stdout=${path}.stdout
    stderr=${path}.stderr
    exstat=${path}.exitstatus
    binary=${path}.bin
    conf=${path}.config
    ${env} /usr/bin/time -pq -o ${time} make -j $nproc 1>${stdout} 2>${stderr}
    echo $? > ${exstat}
    if [ -f ${bin} ] ; then
	cp ${bin} ${binary}
    fi
    cp .config ${conf}
    if [[ $CCACHE == 1 ]] ; then
	ccache -svv > ${path}.ccache-stats
    fi
    git clean -dfx
done
popd
