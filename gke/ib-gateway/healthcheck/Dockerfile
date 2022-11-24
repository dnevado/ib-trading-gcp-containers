FROM python:3.8-slim

# RUN echo "http://dl-8.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories



# Add HDF5 support
# RUN apk add --no-cache --allow-untrusted --repository http://dl-3.alpinelinux.org/alpine/edge/testing hdf5 hdf5-dev
# RUN apk --no-cache --update-cache add  gcc musl-dev python3 py3-pip  py-pip build-base wget linux-headers g++
# RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
WORKDIR /usr/src/app
RUN pip install --upgrade pip 
RUN pip install --extra-index-url https://alpine-wheels.github.io/index numpy
COPY requirements.txt ./
#RUN pip3 install numpy 
RUN pip install --no-cache-dir -r requirements.txt
# COPY ./ibapi/* ./ibapi/
COPY main.py ./
CMD [ "gunicorn", "main:api", "--bind", "0.0.0.0:8000", "--timeout", "60" ]

# NOT BASH AVAILABLE, SH INSTEAD 
# docker run -it fe9c2ca525bf sh    