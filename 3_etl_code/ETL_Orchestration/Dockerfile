# Get Rstudio server from Rocker
FROM rocker/rstudio:4.2.2

MAINTAINER Sam Padmanabhuni <sam.padmanabhuni@helsinki.fi>

# create ETL_Orchestration folder
RUN mkdir /home/rstudio/ETL_Orchestration

# Install system dependencies and Java dependecies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget \
                       gnupg2 \
                       build-essential \
                       libpcre2-dev \
                       liblzma-dev liblzma5 \
                       libicu-dev \
                       libxml2-dev \
                       libpng-dev \
                       software-properties-common && \
    apt-get clean all && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Java 8 repo and install
#RUN add-apt-repository ppa:openjdk-r/ppa && \
#    apt-get update && \
#    apt-get install -y openjdk-8-jdk && \
#    R CMD javareconf
RUN apt-get update -y && \
    apt-get install -y default-jre default-jdk && \
    R CMD javareconf

# Install Python system dependecies
RUN apt-get install -y zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    zlib1g-dev

# Install Python 3.10.6
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar xzf Python-3.10.6.tgz && \
    cd Python-3.10.6 && \
    ./configure && \
    make -j $(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-3.10.6*

# Link python
RUN ln -s /usr/local/bin/python3.10 /usr/local/bin/python

# Install Python packages
COPY ETL_Orchestration/requirements.txt /home/rstudio/ETL_Orchestration
RUN python3.10 -m pip install --upgrade pip && \
    pip3 install -r /home/rstudio/ETL_Orchestration/requirements.txt

# Everytime run bash will restart to get activated
SHELL ["bash","-lc"]

# Set workding directory as ETL_Orhcestration
WORKDIR /home/rstudio/ETL_Orchestration

# Recreate R evnironment
COPY ETL_Orchestration/renv.lock renv.lock
RUN mkdir -p renv
COPY ETL_Orchestration/.Rprofile .Rprofile
COPY ETL_Orchestration/renv/activate.R renv/activate.R
COPY ETL_Orchestration/renv/settings.dcf renv/settings.dcf
RUN R -e "renv::restore()"

# COPY sql and tests
COPY ETL_Orchestration/sql sql
COPY ETL_Orchestration/tests tests
COPY ETL_Orchestration/R R
COPY ETL_Orchestration/R_scripts R_scripts
COPY ETL_Orchestration/config config
COPY ETL_Orchestration/db_drivers db_drivers
COPY ETL_Orchestration/README.* .
