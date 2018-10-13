# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
property :site, String, name_property: true

action :enable do
  site_info = search(:sites, "id: #{new_resource.site}").first

  directory "/etc/ssl/certs" do
    recursive true
    mode '0755'
    owner 'root'
    group 'root'
  end

  directory "/etc/ssl/private" do
    recursive true
    mode '0755'
    owner 'root'
    group 'root'
  end

  openssl_x509_certificate "/etc/ssl/certs/#{new_resource.site}-ssl.crt" do
    common_name "#{new_resource.site}"
    org "#{new_resource.site}"
    country 'HU'
    email "#{site_info['email']}"
    key_file "/etc/ssl/private/#{new_resource.site}-ssl.key"
  end

  # openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
  openssl_dhparam '/etc/ssl/certs/dhparam.pem'

  #execute 'a2enmod ssl'
  apache_module 'ssl' do
    enable true
  end

  #execute 'a2enmod headers'
  apache_module 'headers' do
    enable true
  end

  apache_module 'socache_shmcb' do
    enable true
  end

  # a2enconf ssl-params
  file "#{node['apache']['dir']}/conf-available/ssl-params.conf"

  apache_config 'ssl-params' do
    enable true
  end

  template "/etc/apache2/sites-available/#{new_resource.site}-ssl.conf" do
    source 'ssl-conf.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(config: site_info)
  end

  apache_site "#{new_resource.site}-ssl" do
    enable true
  end
end

action :disable do
  apache_site "#{new_resource.site}-ssl" do
    enable false
  end

  file "/etc/apache2/sites-available/#{new_resource.site}-ssl.conf" do
    action :delete
    only_if { File.exist? "/etc/apache2/sites-available/#{new_resource.site}-ssl.conf" }
  end
end
