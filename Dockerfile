FROM ubuntu:17.04
MAINTAINER Biswadip Maity <biswadip.maity@gmail.com>

# get dependencies for gem 5
RUN apt-get update
RUN apt-get install -y build-essential git-core m4 scons zlib1g zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev swig python-dev python
RUN apt-get clean

# Add dependencies for aladdin

#Boost Graph Library
RUN apt-get install -y libbz2-dev libboost-dev libboost-regex-dev libboost-graph-dev
RUN apt-get clean
ENV BOOST_ROOT="/usr/include/boost"

# LLVM Tracer
RUN apt-get install -y cmake libncurses-dev vim
RUN apt-get clean
WORKDIR /usr/local/src/
RUN git clone https://github.com/ysshao/LLVM-Tracer
ENV TRACER_HOME="/usr/local/src/LLVM-Tracer" 

#TEMPORARY FIX for Ubuntu 17.04
WORKDIR /usr/local/src/LLVM-Tracer/cmake-scripts
RUN sed -i '0,/FINAL_CXX_FLAGS/s//FINAL_CXX_FLAGS "-no-pie"/' buildTracerBitcode.cmake 
WORKDIR /usr/local/src/LLVM-Tracer/
RUN mkdir build
WORKDIR /usr/local/src/LLVM-Tracer/build
RUN cmake .. -DLLVM_ROOT=/usr/local/src/LLVM -DAUTOINSTALL=TRUE
ENV LLVM_HOME="/usr/local/src/LLVM"
ENV PATH="/usr/local/src/LLVM/bin:${PATH}"
ENV LD_LIBRARY_PATH="$LLVM_HOME/lib/:$LD_LIBRARY_PATH"
RUN make
RUN make install

# Aladdin
WORKDIR /usr/local/src/
RUN git clone https://github.com/harvard-acc/gem5-aladdin
WORKDIR /usr/local/src/gem5-aladdin
ENV ALADDIN_HOME="/usr/local/src/gem5-aladdin"
RUN git submodule update --init --recursive

# build it
WORKDIR /usr/local/src/gem5-aladdin
ADD build.bash /usr/local/src/gem5-aladdin/build.bash
RUN chmod ugo+x build.bash
RUN ./build.bash
ENTRYPOINT bash