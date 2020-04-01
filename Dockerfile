FROM python:3-alpine AS builder
ENV PYTHONUNBUFFERED 1

# Install runtime dependencies
RUN apk --update upgrade && \
    apk add --update inotify-tools exiftool zlib jpeg lcms2 tiff openjpeg su-exec && \
    rm -rf /var/cache/apk/*
    
# Install build dependencies
RUN apk --update upgrade && \
    apk add --update git \
                     build-base \
                     jpeg-dev \
                     zlib-dev \
                     lcms2-dev \
                     openjpeg-dev \
                     tiff-dev && \
    rm -rf /var/cache/apk/*

WORKDIR /wheels
RUN git clone https://github.com/jmathai/elodie.git /elodie && \
    pip wheel --no-cache-dir -r /elodie/requirements.txt && \
    rm -rf /elodie/.git

FROM python:3-alpine
LABEL maintainer="pierre@buyle.org"
ENV PYTHONUNBUFFERED 1

# Install runtime dependencies
RUN apk --update upgrade && \
    apk add --update inotify-tools exiftool zlib jpeg lcms2 tiff openjpeg su-exec && \
    rm -rf /var/cache/apk/*

COPY --from=builder /wheels /wheels
COPY --from=builder /elodie /elodie

WORKDIR /elodie
RUN pip install --no-cache-dir -r requirements.txt -f /wheels && \
    rm -rf /wheels
    
COPY entrypoint.sh /entrypoint.sh

ENV PUID=1000
ENV PGID=1000
ENV SOURCE=/source
ENV DESTINATION=/destination
ENV ELODIE_APPLICATION_DIRECTORY=/elodie
ENV DEFAULT_COMMAND=watch

ENTRYPOINT ["/entrypoint.sh"]