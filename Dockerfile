FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.3
LABEL maintainer="IGF"
LABEL version="0.0.1"
LABEL description="Docker image for running viral genome analysis"
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
      libfontconfig1 \
      libxrender1 \
      libreadline6-dev \
      libreadline6 \
      libicu-dev \
      libc6-dev \
      icu-devtools \
      libjpeg-dev \
      libxext-dev \
      libcairo2 \
      libicu55 \
      libicu-dev \
      libjpeg-dev \
      libpng12-dev \
      libfreetype6-dev \
      pkg-config \
      cmake \
      gcc \
      g++ \
      make \
      curl \
      libgcc-5-dev \
      gfortran \
      openjdk-8-jre-headless \
      ca-certificates-java \
      openssl \
      openssh-client \
      libssl-dev \
      libgl1-mesa-glx \
      libncurses5-dev \
      libbz2-1.0 \
      libbz2-dev \
      liblzma5  \
      liblzma-dev \
      git  && \
    curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/home/$NB_USER/.tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile && \
    rm -rf /home/$NB_USER/examples && \
    mkdir /home/$NB_USER/examples
COPY examples/* /home/$NB_USER/examples/
COPY Dockerfile /home/$NB_USER/Dockerfile
COPY environment.yml /home/$NB_USER/environment.yml
USER root
RUN chown -R ${NB_UID} /home/$NB_USER/examples && \
    chown ${NB_UID} /home/$NB_USER/environment.yml
USER $NB_USER
WORKDIR /home/$NB_USER
RUN . /home/$NB_USER/miniconda3/etc/profile.d/conda.sh && \
    conda update -n base -c defaults conda && \
    conda activate notebook-env && \
    conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    jupyter labextension install @jupyterlab/fasta-extension && \
    jupyter labextension install jupyterlab-drawio && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    conda clean -a -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf ${TMPDIR} && \
    mkdir -p ${TMPDIR} && \
    mkdir -p /home/$NB_USER/.cache && \
    find miniconda3/ -type f -name *.pyc -exec rm -f {} \;
RUN mkdir -p /home/$NB_USER/bin && \
    wget -q -O /home/$NB_USER/bin/fastv http://opengene.org/fastv/fastv  && \
    chmod a+x /home/$NB_USER/bin/fastv && \
    wget -q -O /home/$NB_USER/bin/fastp http://opengene.org/fastp/fastp && \
    chmod a+x /home/$NB_USER/bin/fastp && \
    wget -q -O /tmp/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz https://github.com/voutcn/megahit/releases/download/v1.2.9/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
    tar -zxf /tmp/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
    mv MEGAHIT-1.2.9-Linux-x86_64-static /home/$NB_USER/bin/ && \
    wget -q -O /tmp/BBMap_35.34.tar.gz http://downloads.sourceforge.net/project/bbmap/BBMap_35.34.tar.gz && \
    tar -zxf /tmp/BBMap_35.34.tar.gz && \
    mv bbmap /home/$NB_USER/bin/ && \
    wget -q -O /tmp/bowtie2-2.4.1-linux-x86_64.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.1/bowtie2-2.4.1-linux-x86_64.zip/download && \
    unzip /tmp/bowtie2-2.4.1-linux-x86_64.zip && \
    mv bowtie2-2.4.1-linux-x86_64 /home/$NB_USER/bin/ && \
    wget -q -O /tmp/mauve_linux_snapshot_2015-02-13.tar.gz http://darlinglab.org/mauve/snapshots/2015/2015-02-13/linux-x64/mauve_linux_snapshot_2015-02-13.tar.gz && \
    tar -zxf /tmp/mauve_linux_snapshot_2015-02-13.tar.gz && \
    mv mauve_snapshot_2015-02-13 /home/$NB_USER/bin/ && \
    wget -q -O /tmp/mafft-7.450-linux.tgz https://mafft.cbrc.jp/alignment/software/mafft-7.450-linux.tgz && \
    tar -zxf /tmp/mafft-7.450-linux.tgz && \
    mv mafft-linux64 ~/bin/ && \
    wget -q -O /tmp/minimap2-2.17_x64-linux.tar.bz2 https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
    tar -jxf /tmp/minimap2-2.17_x64-linux.tar.bz2 && \
    cp minimap2-2.17_x64-linux/minimap2 /home/$NB_USER/bin/minimap2 && \
    rm -rf minimap2-2.17_x64-linux && \
    chmod a+x /home/$NB_USER/bin/minimap2 && \
    wget -q -O /tmp/samtools-1.10.tar.bz2 https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    tar jxf /tmp/samtools-1.10.tar.bz2 && \
    cd samtools-1.10/ && \
    ./configure --prefix=/home/vmuser/bin/samtools && \
    make && \
    make install && \
    cd - && \
    rm -rf samtools-1.10 && \
    wget -q -O /tmp/bcftools-1.10.2.tar.bz2 https://github.com/samtools/bcftools/releases/download/1.10.2/bcftools-1.10.2.tar.bz2 && \
    tar jxf /tmp/bcftools-1.10.2.tar.bz2 && \
    cd bcftools-1.10.2 && \
    ./configure --prefix=/home/vmuser/bin/bcftools && \
    make && \
    make install && \
    cd - && \
    rm -rf bcftools-1.10.2 && \
    rm -rf ${TMPDIR} && \
    mkdir -p ${TMPDIR} && \
    mkdir -p /home/$NB_USER/.cache
USER root
RUN rm -rf /tmp/*
USER $NB_USER
ENV PATH /home/$NB_USER/bin:${PATH}
ENV PATH /home/$NB_USER/bin/MEGAHIT-1.2.9-Linux-x86_64-static/bin/:${PATH}
ENV PATH /home/$NB_USER/bin/bbmap/:${PATH}
ENV PATH /home/$NB_USER/bin/bowtie2-2.4.1-linux-x86_64/:${PATH}
ENV PATH /home/$NB_USER/bin/mauve_snapshot_2015-02-13/linux-x64/:${PATH}
ENV PATH /home/$NB_USER/bin/mafft-linux64/:${PATH}
ENV PATH /home/$NB_USER/bin/mafft-linux64/mafftdir/bin:${PATH}
ENV PATH /home/$NB_USER/bin/samtools/bin/:${PATH}
ENV PATH /home/$NB_USER/bin/bcftools/bin/:${PATH}
EXPOSE 8888
EXPOSE 4000
CMD [ "notebook" ]
