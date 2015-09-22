FROM debian:jessie

MAINTAINER etimmons@mit.edu

# Install lisps and any system dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y curl build-essential sudo ca-certificates \
    && chown -R root:users /usr/local/ \
    && mkdir -p /etc/common-lisp/source-registry.conf.d \
    && mkdir -p /usr/share/common-lisp/source/slime \
    && mkdir -p /usr/local/share/common-lisp \
    && rm -rf /var/lib/apt

COPY assets/quicklisp-release.key /usr/local/src/
RUN gpg --import /usr/local/src/quicklisp-release.key

COPY assets/lisp-installers /tmp/lisp-installers

ENV SBCL_VERSION=1.2.15
ENV CCL_VERSION=1.10

RUN chmod +x /tmp/lisp-installers/* \
    && find /tmp/lisp-installers -name "*.install" -exec {} \; \
    && rm -rf /tmp/lisp-installers

COPY assets/asdf/*.conf /etc/common-lisp/source-registry.conf.d/

ADD https://beta.quicklisp.org/quicklisp.lisp /usr/local/src/quicklisp/quicklisp.lisp
ADD https://beta.quicklisp.org/quicklisp.lisp.asc /usr/local/src/quicklisp/quicklisp.lisp.asc
COPY assets/install-quicklisp /usr/local/bin/
COPY assets/bin/with-user /usr/local/bin/

RUN chmod +x /usr/local/bin/with-user \
    && mkdir -p /usr/local/share/with-user/post-user-creation-hooks/ \
    && chmod +x /usr/local/bin/install-quicklisp \
    && /usr/local/bin/install-quicklisp \
    && cp /root/.sbclrc /root/.ccl-init.lisp /etc/skel/ \
    && setfacl -d -R -m group:users:rwX /usr/local/ \
    && setfacl -R -m group:users:rwX /usr/local/
