# # # Stage 1: Build dependencies
# # FROM python:3.12-slim AS builder

# # WORKDIR /app
# # RUN apt-get update && apt-get install -y --no-install-recommends \
# #     ca-certificates \
# #     && update-ca-certificates \
# #     && rm -rf /var/lib/apt/lists/*


# # COPY requirements.txt .



# # # Install dependencies to a local folder
# # RUN pip install --no-cache-dir \
# #     --trusted-host pypi.org \
# #     --trusted-host files.pythonhosted.org \
# #     -r requirements.txt
# # # RUN pip install --no-cache-dir -r requirements.txt
# # # Stage 2: Final lightweight image
# # FROM python:3.12-slim AS runner

# # WORKDIR /app

# # # Copy installed packages from builder
# # COPY --from=builder /root/.local /root/.local
# # COPY app.py .
# # COPY templates/ templates/

# # # Make sure scripts installed by pip are in PATH
# # ENV PATH=/root/.local/bin:$PATH
# # ENV PYTHONUNBUFFERED=1

# # # Default environment variables
# # ENV APP_VERSION=1.0.0
# # ENV APP_ENV=Production
# # ENV PORT=5000
# # ENV DB_PATH=/app/database/db.json

# # # Create non-root user and change owner of directory to enable local file writing
# # RUN useradd -u 10011 -m appuser && \
# #     mkdir -p /app/database && \
# #     chown -R appuser:appuser /app

# # USER appuser

# # EXPOSE 5000

# # # Run Flask directly for simple web server execution
# # CMD ["python", "app.py"]


# # Stage 1: Build dependencies
# FROM python:3.12-slim AS builder

# WORKDIR /app

# # SSL fix + tools
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ca-certificates curl \
#     && update-ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# # upgrade pip (חשוב ל-SSL והרבה באגים)
# RUN python -m pip install --upgrade pip setuptools wheel

# COPY requirements.txt .

# # install dependencies into system site-packages (לא user)
# RUN pip install --no-cache-dir \
#     --trusted-host pypi.org \
#     --trusted-host files.pythonhosted.org \
#     -r requirements.txt


# # Stage 2: Final image
# FROM python:3.12-slim AS runner

# WORKDIR /app

# # SSL certs גם ברנר חובה
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ca-certificates \
#     && update-ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# # copy installed python packages correctly
# COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
# COPY --from=builder /usr/local/bin /usr/local/bin

# # app files
# COPY app.py .
# COPY templates/ templates/

# # env
# ENV PYTHONUNBUFFERED=1
# ENV APP_VERSION=1.0.0
# ENV APP_ENV=Production
# ENV PORT=5000
# ENV DB_PATH=/app/database/db.json

# # user
# RUN useradd -u 10011 -m appuser && \
#     mkdir -p /app/database && \
#     chown -R appuser:appuser /app

# USER appuser

# EXPOSE 5000

# CMD ["python", "app.py"]
# Stage 1 - build dependencies offline friendly
FROM python:3.12-slim AS builder

WORKDIR /app

# system certificates (לא פותר נטפרי אבל עדיין טוב)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# copy requirements
COPY requirements.txt .

# התקנה עם trusted-host (חלקי בלבד אבל נשאר)
RUN pip install --no-cache-dir \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org \
    -r requirements.txt


# Stage 2 - runtime
FROM python:3.12-slim

WORKDIR /app

# certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# copy installed python packages from builder
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin

# copy app
COPY app.py .
COPY templates/ templates/
COPY database/ database/

# env
ENV PYTHONUNBUFFERED=1
ENV APP_VERSION=1.0.0
ENV APP_ENV=Production
ENV PORT=5000
ENV DB_PATH=/app/database/db.json

# create user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]