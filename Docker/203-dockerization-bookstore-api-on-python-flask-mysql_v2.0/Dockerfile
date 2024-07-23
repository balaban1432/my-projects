FROM python:alpine
WORKDIR /app
COPY ./requirements.txt .
RUN pip install -r requirements.txt
COPY ./bookstore-api.py .
EXPOSE 80
CMD python bookstore-api.py