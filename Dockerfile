FROM martinney/creadr-base

RUN mkdir -p deploy
WORKDIR deploy

COPY creadr-api/creadr creadr
COPY creadr-api/test test
COPY creadr-api/requirements.txt ./
COPY creadr-api/manage.py ./

RUN pip install --upgrade pip \
    pip install -r ./requirements.txt

RUN mkdir -p www \
    mkdir -p frontend
copy creadr-frontend frontend
RUN cd frontend \
    npm install \
    npm build \
    mv dist ../www \
    cd /deploy
# Setup nginx
RUN rm /etc/nginx/sites-enabled/default
COPY conf/flask.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Setup supervisord
RUN mkdir -p /var/log/supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

# expose port(s)
EXPOSE 80

# Start processes
CMD ["supervisord"]
