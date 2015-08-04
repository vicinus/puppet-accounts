require 'spec_helper'

describe 'accounts::user', :type => :define do
  let(:default_facts) {{
    :concat_basedir => '/tmp',
  }}
  let(:username) { 'rspec' }
  let(:useruid) { '1000' }
  let(:title) { username }
  let(:default_user_values) {{
    :ensure => 'present',
    :shell => '/bin/bash',
    :comment => username,
    :home => "/home/#{username}",
    :uid => nil,
    :gid => nil,
    :groups => [ ],
    :password => '!',
    :managehome => true,
  }}
  let(:default_params) {{
    :managehome => true,
    :home => "/home/#{username}",
  }}

  context 'user creation' do
    [
      {
        :description => 'create user',
        :params => {
          :ensure => 'present',
        },
        :values => {
        },
      },
      {
        :description => 'remove user',
        :params => {
          :ensure => 'absent',
        },
        :values => {
          :ensure => 'absent',
        },
      },
      {
        :description => 'create user with uid',
        :params => {
          :uid => '1000',
        },
        :values => {
          :uid => '1000',
        },
      },
      {
        :description => 'remove user with uid',
        :params => {
          :ensure => 'absent',
          :uid => '1000',
        },
        :values => {
          :ensure => 'absent',
          :uid => '1000',
        },
      },
      {
        :description => 'create user with gid number',
        :params => {
          :gid => '1000',
        },
        :values => {
          :gid => '1000',
        },
      },
      {
        :description => 'remove user with gid number',
        :params => {
          :ensure => 'absent',
          :gid => '1000',
        },
        :values => {
          :ensure => 'absent',
          :gid => '1000',
        },
      },
      {
        :description => 'create user with gid string',
        :params => {
          :gid => 'rspec',
        },
        :values => {
          :gid => 'rspec',
        },
        :pre_condition => 'group { "rspec": }',
      },
      {
        :description => 'create user with gid string and not managedefaultgroup',
        :params => {
          :gid => 'rspec',
          :managedefaultgroup => false,
        },
        :values => {
          :gid => 'rspec',
        },
      },
      {
        :description => 'remove user with gid string',
        :params => {
          :ensure => 'absent',
          :gid => 'rspec',
        },
        :values => {
          :ensure => 'absent',
          :gid => 'rspec',
        },
        :pre_condition => 'group { "rspec": }',
      },
      {
        :description => 'create user with locked',
        :params => {
          :ensure => 'present',
          :locked => 'true',
        },
        :values => {
          :shell => '/usr/sbin/nologin',
        },
        :facts => {
          :operatingsystem => 'debian',
        },
      },
      {
        :description => 'create user with clientversion <= 3.6',
        :params => {
          :ensure => 'present',
        },
        :values => {
          :purge_ssh_keys => nil,
        },
        :facts => {
          :clientversion => '3.6',
        },
      },
      {
        :description => 'create user with clientversion > 3.6',
        :params => {
          :ensure => 'present',
        },
        :values => {
          :purge_ssh_keys => true,
        },
        :facts => {
          :clientversion => '3.7',
        },
      },
    ].each do |param|
      describe param[:description] do
        let(:params) { default_params }
        if param[:pre_condition]
          let(:pre_condition) { param[:pre_condition] }
        end
        if param[:facts]
          let(:facts) { default_facts.merge(param[:facts]) }
        else
          let(:facts) { default_facts }
        end
        it param[:description] do
          params.merge!(param[:params])
          values = default_user_values.merge(param[:values])
          is_expected.to contain_user(username).with(values)
          if params[:gid] =~ /^\d+$/
            is_expected.to contain_group(username).with({
              :gid => values[:gid],
              :ensure => values[:ensure],
            })
          end
          if params[:managehome]
            if params[:ensure] == 'absent'
              is_expected.to contain_file(params[:home])
            else
              is_expected.to contain_accounts__home_dir(params[:home])
            end
          end
        end
      end
    end
  end

  describe "ssh_authorized_key" do
    let(:facts) { default_facts }
    let(:params) {{
      :ssh_keys => [ { 'type' => 'rsa', 'key' => 'dummy', } ],
    }}
    it { is_expected.to contain_ssh_authorized_key("#{username}_0").with({
      :type => 'rsa',
      :key => 'dummy',
    }) }
  end
end
