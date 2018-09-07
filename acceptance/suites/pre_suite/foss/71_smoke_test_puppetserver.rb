# This step needs to execute as quickly as possible after the
# install_puppet_server master step located in 70_install_puppet.rb
#
# This is because beaker uses `puppet resource` to manage the puppetserver
# service which has the side-effect of changing ownership and permissions of key
# paths such as /var/run/puppetlabs and /etc/puppetlabs/puppet/ssl
#
# This side-effect masks legitimate issues we need to test, such as "the
# puppetserver fails to start out of the package"

step "(SERVER-414) Make sure puppetserver can start without puppet resource, "\
  "apply, or agent affecting the known good state of the SUT in a way that "\
  "causes the tests to pass with false positive successful results."

on master, 'yum install -y git'
on master, 'git clone git://github.com/justinstoller/puppetserver-ca-cli.git ' +
           '-b server2304-honor-existing-master-keys /opt/puppetserver-ca'
on master, 'pushd /opt/puppetserver-ca; ' +
           'sed -i "s,0.5.0,0.5.1," /opt/puppetserver-ca/lib/puppetserver/ca/version.rb; ' +
           '/opt/puppetlabs/puppet/bin/gem build puppetserver-ca.gemspec; ' +
           '/opt/puppetlabs/puppet/bin/gem install /opt/puppetserver-ca/puppetserver-ca-0.5.1.gem; ' +
           'popd'

variant = master['platform'].to_array.first
case variant
  when /^(redhat|el|centos)$/
    on(master, "puppetserver ca generate")
    on(master, "service puppetserver start")
    on(master, "service puppetserver status")
    on(master, "service puppetserver stop")
  else
    step "(SERVER-414) Skipped for platform variant #{variant}"
end
