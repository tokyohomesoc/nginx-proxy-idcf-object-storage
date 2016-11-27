FROM alpine:3.4

MAINTAINER Tokyo Home SOC <github@homesoc.tokyo>

# Environment variable
ARG TIMEZONE=Asia/Tokyo
## nginx-ct
ARG NGX_CT_VERSION=1.3.1
## headers-more-nginx-module
ARG HEADERS_MORE_NGINX_MODULE_VERSION=0.31
## nginx
ARG NGX_VERSION=1.11.6
ARG NGX_GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8
ARG NGX_CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        \
        --with-http_ssl_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-compat \
        --with-http_v2_module \
        \
        --add-module=./nginx-ct-$NGX_CT_VERSION \
        --add-module=./headers-more-nginx-module-$HEADERS_MORE_NGINX_MODULE_VERSION \
    "

RUN \
       addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    # TIMEZONE
    && apk add --no-cache --virtual .build-tzdata \
         tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del .build-tzdata \
    \
    # nginx packages
    && apk add --no-cache --virtual .build-nginx \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
    && curl -fSL http://nginx.org/download/nginx-$NGX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL http://nginx.org/download/nginx-$NGX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$NGX_GPG_KEYS" \
    && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && rm -r "$GNUPGHOME" nginx.tar.gz.asc \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-$NGX_VERSION \
    \
    ## nginx-ct
    # https://github.com/grahamedgecombe/nginx-ct
    && curl -fSL https://github.com/grahamedgecombe/nginx-ct/archive/v$NGX_CT_VERSION.tar.gz \
        -o nginx-ct.tar.gz \
    && tar -zxC ./ -f nginx-ct.tar.gz \
    && rm nginx-ct.tar.gz \
    \
    ## headers-more-nginx-module
    # https://github.com/openresty/headers-more-nginx-module
    && curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_NGINX_MODULE_VERSION.tar.gz \
        -o headers-more-nginx-module.tar.gz \
    && tar -zxC ./ -f headers-more-nginx-module.tar.gz \
    && rm headers-more-nginx-module.tar.gz \
    \
    && ./configure $NGX_CONFIG --with-debug \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && mv objs/nginx objs/nginx-debug \
    && ./configure $NGX_CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && rm -rf /usr/src/nginx-$NGX_VERSION \
    \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-nginx \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]