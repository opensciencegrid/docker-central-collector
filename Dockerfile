FROM opensciencegrid/software-base:3.5-el8-release
LABEL maintainer "OSG Software <help@opensciencegrid.org>"

RUN    yum module enable -y mod_auth_openidc \
    && yum install -y htcondor-ce-collector \
                      htcondor-ce-view \
                      mod_ssl \
                      # ^^^ Doing SSL termination in the pod
                      perl-LWP-Protocol-https \
                      # ^^^ for fetch-crl, in the rare case that the CA forces HTTPS
                      mod_auth_openidc \
                      # ^^^ Install mod_auth_openidc from module
                      inotify-tools \
                      # ^^^ Detect certificate changes and reload httpd
    && yum clean all \
    && rm -rf /var/cache/yum/

# Create home directory for registry user
RUN mkdir /var/lib/condor-ce/webapp

# Disable Globus (GSS_ASSIST_GRIDMAP) lookups
RUN rm /etc/condor-ce/mapfiles.d/50-gsi-callout.conf

COPY etc/supervisord.d/*      /etc/supervisord.d/
COPY etc/condor-ce/config.d/* /etc/condor-ce/config.d/
COPY etc/httpd/conf.d/*       /etc/httpd/conf.d/
COPY auto-reload.sh           /usr/local/sbin/

RUN  chmod a+x /usr/local/sbin/auto-reload.sh
