FROM debian:latest
RUN apt-get update 
RUN apt-get install -y bash 
RUN apt-get install -y htop 
RUN apt-get install -y vim 
RUN apt-get install -y net-tools
ENV OWNER="Nour Eddine"
CMD ["sleep","3600"]
RUN useradd -m nonroot
USER nonroot

