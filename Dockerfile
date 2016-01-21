FROM debian:jessie

MAINTAINER etimmons@mit.edu

# Install tools that will be needed even after build time. Additionally, created
# a standard, non-root, user
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    # Needed by ECL (I think) to compile lisp files and used by CFFI (used
    # commonly enough that it should stay)
    build-essential \
    # Needed by ABCL (I'm not familiar enough with ABCL to know if it needs
    # javac at runtime or access to Java's graphical libraries, so this may need
    # to eventually change)
    openjdk-7-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt \
    && adduser --gecos "Lisp user." lisp

COPY assets/lisp-installers /tmp/lisp-installers

ENV SBCL_VERSION=1.3.1 CCL_VERSION=1.11 ECL_VERSION=16.0.0 ABCL_VERSION=1.3.3

RUN chmod +x /tmp/lisp-installers/* \
    && /tmp/lisp-installers/init \
    && find /tmp/lisp-installers -name "*.install" -exec {} \; \
    && /tmp/lisp-installers/clean \
    && rm -rf /tmp/lisp-installers

# Set up folders and volumes.
RUN mkdir -p /etc/common-lisp/asdf-output-translations.conf.d \
    && mkdir -p /etc/common-lisp/source-registry.conf.d \
    && mkdir -p /var/cache/common-lisp \
    && chmod 1777 /var/cache/common-lisp \
    && mkdir -p /usr/share/common-lisp/source \
    && mkdir -p /usr/share/common-lisp/slime \
    && chmod 1777 /usr/share/common-lisp/source


COPY assets/asdf/50-default-translations.conf /etc/common-lisp/asdf-output-translations.conf.d/
COPY assets/asdf/50-slime.conf /etc/common-lisp/source-registry.conf.d/
