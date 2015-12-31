#
# Cookbook Name:: jenkins
# Recipe:: install
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

group node['jenkins']['group'] do
  group_name node['jenkins']['group']
  action :create
end

user "jenkins" do
   group node['jenkins']['group']
   home  node['jenkins']['jenkins_home']
   password node['jenkins']['password']
   action :create
end

directory node['jenkins']['jenkins_home'] do
  owner     node['jenkins']['user']
  group     node['jenkins']['group']
  mode      '0755'
  recursive true
end

directory node['jenkins']['log_directory'] do
  owner     node['jenkins']['user']
  group     node['jenkins']['group']
  mode      '0755'
  recursive true
end

rpm = "jenkins-#{node['jenkins']['version']}-1.1.noarch.rpm"
temp_dir = Chef::Config[:file_cache_path]

remote_file File.join(temp_dir, rpm) do
  source "http://pkg.jenkins-ci.org/redhat/#{rpm}"
  owner "root"
  group "root"
  mode "0755"
  not_if "test -e #{temp_dir}/#{rpm}"
end

package "jenkins" do
  action :install
  source "#{temp_dir}/#{rpm}"
  provider Chef::Provider::Package::Rpm
  not_if "rpm -q jenkins"
end
