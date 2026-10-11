FROM python:3.11-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    libpq-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /venv

COPY requirements.txt /tmp/requirements.txt

RUN /venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt


FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libmariadb3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /venv /venv
COPY app.py .

ENV PATH=/venv/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE=1

ARG VERSION
RUN echo "$VERSION" > /app/VERSION

STOPSIGNAL SIGINT

CMD ["python", "app.py"]
