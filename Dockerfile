FROM node:lts-alpine as build
WORKDIR /app/react_frontend
COPY ./react_frontend/package.json ./
RUN npm install
COPY ./react_frontend ./
RUN npm run build


FROM python:3.7
EXPOSE 5000
WORKDIR /app
ENV ACCEPT_EULA=Y
RUN apt-get update -y && apt-get update \
  && apt-get install -y --no-install-recommends curl gcc g++ gnupg unixodbc-dev
COPY requirements.txt ./requirements.txt

COPY . .
ENV CLASSPATH=lib/terajdbc4.jar:lib/tdgssconfig.jar:${CLASSPATH}

#unixODBC
#ADD unixODBC-2.3.9.tar.gz /tmp/
#RUN cd /tmp/unixODBC-2.3.9; ./configure; make; make install

#run tdobc
RUN mkdir /usr/lib64/
ADD tdodbc1710__ubuntu_x8664.17.10.00.10-1.tar.gz .
RUN tar -xvzf tdodbc1710__ubuntu_x8664.17.10.00.10-1.tar.gz
RUN dpkg -i tdodbc1710/tdodbc1710-17.10.00.10-1.x86_64.deb
RUN odbcinst -j
RUN /bin/bash /etc/profile


RUN cp odbc.ini /etc/odbc.ini
RUN cp odbcinst.ini /etc/odbcinst.ini

ENV ODBCINI=/etc/odbc.ini
ENV ODBCINST=/etc/odbcinst.ini
ENV LD_LIBRARY_PATH=/opt/teradata/client/17.10/odbc_64/lib/:/opt/teradata/client/17.10/lib64/:$LD_LIBRARY_PATH

RUN pip3 install -r requirements.txt

#RUN apt-get install nodejs -yq

COPY --from=build /app/react_frontend/build/ ./frontend/build

ENTRYPOINT ["python"]
CMD ["app.py"]