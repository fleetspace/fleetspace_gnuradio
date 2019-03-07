FROM ubuntu:18.04

ENV num_threads 2
ENV uhd_branch v3.12.0.0
ENV gr_branch v3.7.12.0

RUN apt-get update && apt-get dist-upgrade -yf && apt-get clean && apt-get autoremove
RUN apt-get install -y \
        build-essential \
        cmake \
        git \
        libasound2-dev \
        liblog4cpp5-dev \
        libboost-all-dev \
        libfftw3-3 \
        libfftw3-dev \
        libgsl-dev \
        libqwt-dev \
        libqwt5-qt4 \
        libusb-1.0-0 \
        libusb-1.0-0-dev \
        libzmq3-dev \
        pkg-config \
        python-cairo-dev \
        python-cheetah \
        python-dev \
        python-gtk2 \
        python-lxml \
        python-mako \
        python-numpy \
        python-qt4 \
        python-qwt5-qt4 \
        python-zmq \
        swig \
        libcppunit-dev \
        python-requests

WORKDIR /opt/
RUN git clone https://github.com/EttusResearch/uhd.git
WORKDIR /opt/uhd/host
RUN git checkout ${uhd_branch}

RUN mkdir build
WORKDIR /opt/uhd/host/build
RUN cmake ../
RUN make -j${num_threads}
RUN make install
RUN ldconfig

WORKDIR /opt/
RUN git clone --recursive https://github.com/gnuradio/gnuradio.git
WORKDIR /opt/gnuradio
RUN git checkout ${gr_branch}
RUN mkdir build
WORKDIR /opt/gnuradio/build
RUN cmake ../
RUN make -j${num_threads}
RUN make install
RUN ldconfig

RUN /usr/local/lib/uhd/utils/uhd_images_downloader.py

WORKDIR /opt/
RUN git clone https://github.com/daniestevez/libfec
WORKDIR /opt/libfec
RUN ./configure
RUN make
RUN make install

WORKDIR /opt/
RUN git clone https://github.com/construct/construct
WORKDIR /opt/construct
RUN git checkout v2.8.12
RUN python ./setup.py install

WORKDIR /opt/
RUN git clone https://github.com/daniestevez/gr-satellites
WORKDIR /opt/gr-satellites
RUN git checkout v1.2.0
RUN mkdir /opt/gr-satellites/build
WORKDIR /opt/gr-satellites/build
RUN cmake ..
RUN make -j${num_threads}
RUN make install
RUN ldconfig

WORKDIR /opt/
RUN git clone https://github.com/daniestevez/gr-kiss
RUN mkdir /opt/gr-kiss/build
WORKDIR /opt/gr-kiss/build
RUN cmake ..
RUN make -j${num_threads}
RUN make install
RUN ldconfig

WORKDIR /opt/
RUN git clone https://github.com/bistromath/gr-ais
RUN mkdir /opt/gr-ais/build
WORKDIR /opt/gr-ais/build
RUN cmake ..
RUN make -j${num_threads}
RUN make install
RUN ldconfig



CMD ["/bin/bash"]