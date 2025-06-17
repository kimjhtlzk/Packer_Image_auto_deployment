#!/bin/bash
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

source /etc/profile

PUPPET_SERVER_EXT_INSTALL () {
# PUPPET SERVER (EXT) 
echo "===================================="
echo "Standalone Puppetserver (ext) Install"
echo "foreman-installer \\
  --no-enable-foreman \\
  --no-enable-foreman-plugin-puppet \\
  --no-enable-foreman-cli \\
  --no-enable-foreman-cli-puppet \\
  --enable-puppet \\
  --puppet-server-ca=false \\
  --enable-foreman-proxy \\
  --foreman-proxy-puppetca=false \\
  --foreman-proxy-foreman-base-url=https://foreman.example.com \\
  --foreman-proxy-trusted-hosts=foreman.example.com \\
  --foreman-proxy-oauth-consumer-key=<key here> \\
  --foreman-proxy-oauth-consumer-secret=<secret here>"
echo "===================================="

echo "FOREMAN SERVER URL 정보"
echo "(Option) foreman-proxy-foreman-base-url 입력하세요 "
read FOREMAN_URL

echo "FOREMAN SERVER DNS 정보"
echo "(Option) foreman-proxy-trusted-hosts 입력하세요 "
read FOREMAN_DNS

echo "===================================="
echo "Refer to the command results below on the foreman server \\
      (Foreman Server) # foreman-rake config | grep oauth_consumer \\
     "
echo "===================================="

echo "FOREMAN SERVER oauth key 정보"
echo "(Option) foreman-proxy-oauth-consumer-key 입력하세요 "
read FOREMAN_OAUTH_KEY

echo "FOREMAN SERVER oauth secret 정보"
echo "(Option) foreman-proxy-oauth-consumer-secret 입력하세요 "
read FOREMAN_OAUTH_SECRET

echo "
foreman-installer \\
  --no-enable-foreman \\
  --no-enable-foreman-plugin-puppet \\
  --no-enable-foreman-cli \\
  --no-enable-foreman-cli-puppet \\
  --enable-puppet \\
  --puppet-server-ca=false \\
  --enable-foreman-proxy \\
  --foreman-proxy-puppetca=false \\
  --foreman-proxy-foreman-base-url=${FOREMAN_URL} \\
  --foreman-proxy-trusted-hosts=${FOREMAN_DNS} \\
  --foreman-proxy-oauth-consumer-key=${FOREMAN_OAUTH_KEY} \\
  --foreman-proxy-oauth-consumer-secret=${FOREMAN_OAUTH_SECRET}"

echo "Do you want to apply the above content? (y/n)"
read CONFIRM

case $CONFIRM in
    y|yes)
        foreman-installer \
          --no-enable-foreman \
          --no-enable-foreman-plugin-puppet \
          --no-enable-foreman-cli \
          --no-enable-foreman-cli-puppet \
          --enable-puppet \
          --puppet-server-ca=false \
          --enable-foreman-proxy \
          --foreman-proxy-puppetca=false \
          --foreman-proxy-foreman-base-url=${FOREMAN_URL} \
          --foreman-proxy-trusted-hosts=${FOREMAN_DNS} \
          --foreman-proxy-oauth-consumer-key=${FOREMAN_OAUTH_KEY} \
          --foreman-proxy-oauth-consumer-secret=${FOREMAN_OAUTH_SECRET}
    ;;
    *)
        echo "The task was canceled because you did not approve its content."
    ;;
esac

}

# Pre-work setting notice
echo "
  Pre-work is required for the next task? \\
  Please check the check items below before working.\\
  [Check List] \\
  1) (option) Do you have any information to type in /etc/puppetlabs/puppet/puppet.conf? (y/n) \\
     -> dns-alt-names=${DNS_ALT_NAMES} \\
  2) (required) Did you proceed with the Puppet bootstrap work? \\
     -> puppet ssl bootstrap --server ${FOREMAN_DNS} \\
  3) (required) Foreman Server File[/etc/hosts] edited or (New) puppetserver DNS Are you registered? \\
"

# (1) Pre-work Check list
echo "1) (option) Do you have any DNS information to type in /etc/puppet wrap/puppet/puppet.conf? (y/n)"
read CONFIRM

case $CONFIRM in
    y|yes)
        echo "Please enter dns-alt-names information"
        read DNS_ALT_NAMES
        echo "dns_alt_names=${DNS_ALT_NAMES}" > /etc/puppetlabs/puppet/puppet.conf
    ;;
    n|no)
        echo "You do not want that option, so we will proceed to the next step."
    ;;
esac



# (2) Pre-work Check list
echo "2) (required) Perform Puppet bootstrap operations"

if [ -f /etc/puppetlabs/puppet/ssl/certs/$(hostname -f).pem ]; then
  echo "File /etc/puppetlabs/puppet/ssl/certs/$(hostname -f).pem has been verified."
else 
  echo "(new task) Please enter Foreman Server DNS information"
  read FOREMAN_DNS
  puppet ssl bootstrap --server ${FOREMAN_DNS}
fi


# Verify that the configuration is progressing by completing the pre-work
echo "Is it okay to proceed with the next task after all the preparations for the pre-work are completed? (y/n)"
read CONFIRM
case $CONFIRM in
    y|yes)
        PUPPET_SERVER_EXT_INSTALL
    ;;
    *)
        echo "The task was canceled because you did not approve its content."
    ;;
esac