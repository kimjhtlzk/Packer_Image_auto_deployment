#!/bin/bash
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

# foreman install
foreman-installer --foreman-initial-admin-password flsnrtm@1234 \
--puppet-autosign-entries *.com2.kr \
--puppet-server-ca-allow-sans=true \
--puppet-dns-alt-names "puppet" \
--puppet-dns-alt-names "puppet-lb.com2.kr" \
--puppet-dns-alt-names "puppet-ca.com2.kr" \
