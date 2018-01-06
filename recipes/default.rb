#
# Cookbook:: amti_data
# Recipe:: default
#
# Copyright:: 2018, Advanced Marketing Training, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Drop db
execute "drop db if exists" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e 'DROP DATABASE IF EXISTS #{node[:dbconf][:database]};'"
end

# Create db
execute "Create database" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e 'CREATE DATABASE #{node[:dbconf][:database]} DEFAULT CHARACTER SET `utf8`;'"
  action :run
end

#drop user
#execute "drop user if exists" do
#  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"DROP USER IF EXISTS '#{node[:dbconf][:db_username]}'@'%';\""
#end

execute "Create database user" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"CREATE USER IF NOT EXISTS '#{node[:dbconf][:db_username]}'@'%' IDENTIFIED BY '#{node[:dbconf][:db_password]}';\""
end

execute "Give root access from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;\""
  action :run
end

execute "Give #{node[:dbconf][:db_username]} access to #{node[:dbconf][:database]} from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON #{node[:dbconf][:database]} .* TO '#{node[:dbconf][:db_username]}'@'%' WITH GRANT OPTION;\""
  action :run
end

if 'null' != node['dbconf']['socket']
    #socket = '-S "+node['dbconf']['socket']"
end

#execute "import database" do
#end