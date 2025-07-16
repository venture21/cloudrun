# Python 3.11 slim 이미지 사용
FROM python:3.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 패키지 업데이트
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 복사 및 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1

# Cloud Run은 PORT 환경변수를 자동으로 설정함
# 기본값은 8080
EXPOSE 8080

# Gunicorn으로 애플리케이션 실행
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app