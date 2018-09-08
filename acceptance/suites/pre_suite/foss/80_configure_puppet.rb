step "Configure puppet.conf" do
  hostname = on(master, 'facter hostname').stdout.strip
  fqdn = on(master, 'facter fqdn').stdout.strip
  dir = master.tmpdir(File.basename('/tmp'))

  lay_down_new_puppet_conf( master,
                           {"main" => { "dns_alt_names" => "puppet,#{hostname},#{fqdn}",
                                       "verbose" => true }}, dir)

  on master, %q{/opt/puppetlabs/puppet/bin/ruby -e 'require "hocon/parser/config_document_factory"; file = "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf"; o = Hocon::Parser::ConfigDocumentFactory.parse_file(file); n = o.set_value("certificate-authority.allow-subject-alt-names", "true"); File.write(file, n.render)'}

end
