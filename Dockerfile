FROM tuxmake/x86_64_gcc-14:latest

# https://github.com/foss-for-synopsys-dwc-arc-processors/toolchain/issues/207#issuecomment-557520951
# RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
RUN apt-get -y update && apt-get install -y	\
    ccache					\
    time					\
    curl					\
    libpam0g-dev				\
    bison					\
    build-essential				\
    curl					\
    flex					\
    git						\
    gnat					\
    libncurses5-dev				\
    m4						\
    zlib1g-dev					\
    python3-pip					\
    less					\
    strace

# RUN pip3 install requests

WORKDIR /home
