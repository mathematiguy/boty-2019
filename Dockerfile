FROM docker.dragonfly.co.nz/dragonverse-18.04:latest

RUN apt update

# Install python3
RUN apt install -y python3-dev python3-pip

RUN Rscript -e 'install.packages("bookdown")'

# Install requirements
COPY requirements.txt /root/requirements.txt
RUN pip3 install -r /root/requirements.txt
