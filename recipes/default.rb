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
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"DROP DATABASE IF EXISTS #{node[:dbconf][:database]};\""
  action :run
end

# Create db
execute "Create database" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"CREATE DATABASE #{node[:dbconf][:database]} DEFAULT CHARACTER SET utf8;\""
  action :run
end

#drop user if user file exists
user_created_file = "/home/vagrant/.#{node[:dbconf][:db_username]}_created"
if File.exist?(user_created_file)
    execute "drop user" do
      command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"DROP USER '#{node[:dbconf][:db_username]}'@'%';\" && rm  /home/vagrant/.#{node[:dbconf][:db_username]}_created"
      action :run
    end
end

execute "Create database user" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"CREATE USER '#{node[:dbconf][:db_username]}'@'%' IDENTIFIED BY '#{node[:dbconf][:db_password]}';\" && touch /home/vagrant/.#{node[:dbconf][:db_username]}_created"
    creates  "/home/vagrant/.#{node[:dbconf][:db_username]}_created"
    action :run
end

execute "Give root access from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;\""
  action :run
end

execute "Give #{node[:dbconf][:db_username]} access to #{node[:dbconf][:database]} from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON #{node[:dbconf][:database]} .* TO '#{node[:dbconf][:db_username]}'@'%' WITH GRANT OPTION;\""
  action :run
end

if 'null' == node['dbconf']['socket']
    execute "import database" do
       command "mysql -u root -p"+node['mysql']['server_root_password']+" "+node['dbconf']['database']+" < /vagrant/cookbooks/amti_data/files/"+node['dbconf']['file_folder']+"/"+node['dbconf']['database']+".sql"
    end
else
    execute "import database with socket" do
        command "mysql -S "+node['dbconf']['socket']+" -u root -p"+node['mysql']['server_root_password']+" "+node['dbconf']['database']+" < /vagrant/cookbooks/amti_data/files/"+node['dbconf']['file_folder']+"/"+node['dbconf']['database']+".sql"
    end
end

execute "flush privs" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"FLUSH PRIVILEGES;\""
end