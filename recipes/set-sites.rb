#
# Cookbook:: apache
# Recipe:: set-sites
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#sites = %w ( test.org example.com proba.hu);
sites = data_bag('sites')
hosts = {}
sites.each do |site|
  node.default['config'] = data_bag_item(:sites, site)
  hosts[node['config']['server']] = node['config']['alias']

  template "/etc/apache2/sites-available/#{site}.conf" do
    source 'conf.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(config: node['config'])
  end

  directory "#{node['config']['rootdir']}" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  template "#{node['config']['rootdir']}/index.html" do
    source 'index.html.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(site: site)
  end

  if !node['config']['https'].nil? && node['config']['https'] then
    node.default['apache']['listen'] << '*:443' if !(node.default['apache']['listen'].include?('*:443'))

    apache_set_ssl "#{node['config']['id']}"
  end

  apache_site "#{site}" do
    enable true
  end
end

template '/etc/hosts' do
  source 'hosts.erb'
  mode '0755'
  owner 'root'
  group 'root'
  variables(hosts: hosts)
end
