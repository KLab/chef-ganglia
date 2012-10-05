directory "/etc/ganglia-webfrontend"

case node[:platform]
when "ubuntu", "debian"
  package "ganglia-webfrontend"

  link "/etc/apache2/sites-enabled/ganglia" do
    to "/etc/ganglia-webfrontend/apache.conf"
    notifies :restart, "service[apache2]"
  end

when "amazon"
  package "ganglia-web"
#  link "/etc/httpd/sites-enabled/ganglia" do
#    to "/etc/httpd/conf.d/ganglia.conf"
#    notifies :restart, "service[apache2]"
#  end

when "redhat", "centos", "fedora"
  package "httpd"
  package "php"
  include_recipe "ganglia::source"
  include_recipe "ganglia::gmetad"

  execute "copy web directory" do
    command "cp -r web /var/www/html/ganglia"
    creates "/var/www/html/ganglia"
    cwd "/usr/src/ganglia-#{node[:ganglia][:version]}"
  end
end

service "apache2" do
  service_name "httpd" if platform?( "redhat", "centos", "fedora", "amazon" )
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
