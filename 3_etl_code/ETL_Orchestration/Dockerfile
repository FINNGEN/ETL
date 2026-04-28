# Get Rstudio server from Rocker
FROM rocker/rstudio:4.4.1

LABEL org.opencontainers.image.authors="sam.padmanabhuni@helsinki.fi"

# Copy ETL_Orchestration folder
RUN mkdir -p /home/rstudio
WORKDIR /home/rstudio
COPY --chown=rstudio . .

# Install System, Python and Java dependecies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential \
     gnupg2 \
     jq \
     libdeflate-dev \
     libpcre2-dev \
     liblzma-dev \
     liblzma5 \
     libicu-dev \
     libxml2-dev \
     libpng-dev \
     libncurses5-dev \
     libgdbm-dev \
     libnss3-dev \
     libssl-dev \
     libreadline-dev \
     libffi-dev \
     libsqlite3-dev \
     libbz2-dev \
     software-properties-common \
     unzip \
     wget \
     xclip \
     zlib1g-dev && \
     apt-get clean all && \
     apt-get purge && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install default JAVA jre and jdk
RUN apt-get update -y && \
    apt-get install -y default-jre default-jdk && \
    R CMD javareconf

# Install Python 3.10.6
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar xzf Python-3.10.6.tgz && \
    cd Python-3.10.6 && \
    ./configure --enable-shared && \
    make -j $(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-3.10.6* && \
    ldconfig -v

# Link python
RUN ln -s /usr/local/bin/python3.10 /usr/local/bin/python

# Fix format-security compiler error globally for all R package builds
RUN sed -i 's/-Werror=format-security//g' /usr/local/lib/R/etc/Makeconf

# Fix rJava compilation flag and set up Makevars for rstudio user
RUN mkdir -p /home/rstudio/.R && \
    echo 'CFLAGS += -Wno-format-security' >> /home/rstudio/.R/Makevars && \
    echo 'CXXFLAGS += -Wno-format-security' >> /home/rstudio/.R/Makevars && \
    chown -R rstudio:rstudio /home/rstudio/.R

# Set the user rstudio here
USER rstudio

# Install Python packages
RUN python3.10 -m pip install --upgrade pip

# Recreate R evnironment
ENV RENV_PATHS_LIBRARY=renv/library
RUN R -e "renv::restore()"

# Set it back to root.
# This step very much is necessary or else the docker image will not run
USER root
