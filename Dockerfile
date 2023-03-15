FROM python:3.6
COPY app/helloworld-app.py /app/
WORKDIR /app
RUN pip install flask 
CMD ["python", "helloworld-app.py"]
