FROM ubuntu:16.04

# no tty
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update --fix-missing
RUN apt-get install -y python python-pip python-virtualenv nginx supervisor
#RUN apt-get install -y python-dev libffi-dev libssl-dev
RUN mkdir -p deploy
WORKDIR deploy

COPY creadr-api/creadr creadr
COPY creadr-api/test test
COPY creadr-api/requirements.txt ./
COPY creadr-api/manage.py ./

RUN pip install --upgrade pip
#RUN pip install --upgrade pyopenssl ndg-httpsclient pyasn1
RUN pip install -r ./requirements.txt

# Setup nginx
RUN rm /etc/nginx/sites-enabled/default
COPY creadr-api/conf/flask.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Setup supervisord
RUN mkdir -p /var/log/supervisor
COPY creadr-api/conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY creadr-api/conf/gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

# expose port(s)
EXPOSE 80

# Start processes
CMD ["supervisord"]
