FROM python:latest
RUN apt-get update
RUN apt-get install -y curl
ADD . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD python app.py
