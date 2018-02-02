#
# Cookbook:: amti_data
# Recipe:: db2
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
execute "drop db2 if exists" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"DROP DATABASE IF EXISTS #{node[:dbconf2][:database]};\""
  action :run
end

# Create db
execute "Create database2" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"CREATE DATABASE #{node[:dbconf2][:database]} DEFAULT CHARACTER SET utf8;\""
  action :run
end

#drop user if user file exists
user_created_file = "/home/vagrant/.#{node[:dbconf2][:db_username]}_created"
if File.exist?(user_created_file)
    execute "drop user" do
      command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"DROP USER '#{node[:dbconf2][:db_username]}'@'%';\" && rm  /home/vagrant/.#{node[:dbconf2][:db_username]}_created"
      action :run
    end
end

execute "Create database2 user" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"CREATE USER '#{node[:dbconf2][:db_username]}'@'%' IDENTIFIED BY '#{node[:dbconf2][:db_password]}';\" && touch /home/vagrant/.#{node[:dbconf2][:db_username]}_created"
    creates  "/home/vagrant/.#{node[:dbconf2][:db_username]}_created"
    action :run
end

execute "Give root access from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '#{node[:mysql][:server_root_password]}' WITH GRANT OPTION;\""
  action :run
end

execute "Give #{node[:dbconf2][:db_username]} access to #{node[:dbconf2][:database]} from everywhere" do
  command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"GRANT ALL PRIVILEGES ON #{node[:dbconf2][:database]} .* TO '#{node[:dbconf2][:db_username]}'@'%' WITH GRANT OPTION;\""
  action :run
end

if 'null' == node['dbconf2']['socket']
    execute "import database" do
       command "mysql -u root -p"+node['mysql']['server_root_password']+" "+node['dbconf2']['database']+" < /vagrant/cookbooks/amti_data/files/default/"+node['dbconf2']['database']+".sql"
    end
else
    execute "import database with socket" do
        command "mysql -S "+node['dbconf2']['socket']+" -u root -p"+node['mysql']['server_root_password']+" "+node['dbconf2']['database']+" < /vagrant/cookbooks/amti_data/files/default/"+node['dbconf2']['database']+".sql"
    end
end

execute "flush privs" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"FLUSH PRIVILEGES;\""
end