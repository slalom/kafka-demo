FROM python:3.9

ADD requirements.txt .
RUN pip install -U pip
RUN pip install -r requirements.txt
ADD *.py ./

CMD ["python", "app.py"]