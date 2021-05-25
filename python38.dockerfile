FROM python:3.8-buster
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor
COPY ./configs/python38/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf