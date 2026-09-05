FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ingester.py pemetaan.yaml ./
ENV PYTHONUNBUFFERED=1
CMD ["python", "ingester.py"]
