# Cookbook Name:: install_evaping
# Recipe:: default
# Script to install Eva Ping Service 2.0
# Copyright (c) 2017 The Authors, All Rights Reserved.

#
# Variables
#
node_name = Chef.run_context.node.name.to_s
ip_file_path  = node["evaping"]["ip_file"]
install_command = <<-SCRIPT
cd C:\\EvaPing
C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\InstallUtil.exe EvaPingSrvs.exe
SCRIPT

#
# Main process
#
directory 'C:\Eva\Log' do
  action :create
end

ruby_block 'Install EvaPing 2.0' do
  block do
    evaping = powershell_out!(install_command)
    Chef::Log.info(evaping.stdout.chop)
  end
  action :nothing
end

ruby_block 'Create ip.txt file' do
  block do
    File.open('C:\Eva\ip.txt', 'w') { |file| file.write "#{node_name};#{Tools.get_ips(node_name, ip_file_path)}" }
  end
  action :nothing
  notifies :run, 'ruby_block[Install EvaPing 2.0]', :immediately
end

cookbook_file ip_file_path do
  source File.basename(ip_file_path)
  action :nothing
  notifies :run, 'ruby_block[Create ip.txt file]', :immediately
end

windows_zipfile "C:\\" do
  source node[:evaping][:url]
  action :unzip
  notifies :create, "cookbook_file[#{ip_file_path}]", :immediately
end

ruby_block 'Send Email EvaPing' do
  block do
      f = Tools.fetch 'http://localhost:8080/Eva/apilocalidad/version'
      message = "Eva Ping Service 2.0 is running in #{f["codLocalidad"]} #{f["descripLocalidad"]} !"
      Chef::Log.info(message)
      Tools.simple_email node["mail"]["to"], :message => message, :subject => "Chef Install on Node #{f["codLocalidad"]}"
  end
end
