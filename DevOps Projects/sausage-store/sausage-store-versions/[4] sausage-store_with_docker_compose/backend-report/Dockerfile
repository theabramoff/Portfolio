FROM python:latest
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD app.py /app
ENTRYPOINT ["python"]
CMD ["app.py"]
EXPOSE 8080