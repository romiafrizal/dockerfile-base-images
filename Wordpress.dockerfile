FROM wordpress:5.4.2-php7.4-apache
RUN  echo "file_uploads = On\n" \
     "memory_limit = 500M\n" \
     "upload_max_filesize = 500M\n" \
     "post_max_size = 500M\n" \
     "max_execution_time = 600\n" \
      > /usr/local/etc/php/conf.d/uploads.ini
RUN apt update && apt-get install -y gnupg gnupg1 gnupg2 
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \ 
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \ 
    && apt-get update -y && apt-get install google-cloud-sdk -y

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]