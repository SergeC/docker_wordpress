FROM ubuntu:xenial

EXPOSE 80

# Install required software
RUN useradd -r -s /bin/false varnishd && \
    apt-get update && apt-get install --allow-unauthenticated -y varnish && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY default.vcl /etc/varnish/default.vcl

CMD ["varnishd", "-j", "unix", "-F", "-f", "/etc/varnish/default.vcl", "-s", "malloc,512m", "-a", "0.0.0.0:80", "-p", "http_req_hdr_len=16384", "-p", "http_resp_hdr_len=16384"]