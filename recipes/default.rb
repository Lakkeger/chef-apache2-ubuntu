#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

apt_update 'Updating packages' do
  frequency 86_400
  action :periodic
end

package 'apache2'

service 'apache2' do
  supports :status => true
  action [:enable, :start]
end
