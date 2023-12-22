FROM python:3.9

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY DataCollector /app/DataCollector

COPY scientific_analyzer.py .

CMD [ "python" , "scientific_analyzer.py"]


