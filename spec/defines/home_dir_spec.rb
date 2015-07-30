require 'spec_helper'

describe 'accounts::home_dir', :type => :define do
  let(:facts) {{ :concat_basedir => '/tmp', }}
  let :title do
    '/home/rspec'
  end
  let :params do
    {
      :user => 'rspec',
    }
  end

  context 'with group => undef' do
    it { is_expected.to contain_file('/home/rspec/.ssh').with(
      :ensure => 'directory',
      :mode => '0700',
      :owner => 'rspec',
      :group => nil,
    ) }
    it { is_expected.to contain_file('/home/rspec/.ssh/authorized_keys').with(
      :ensure => 'file',
      :mode => '0600',
      :owner => 'rspec',
      :group => nil,
    ) }
  
    it { is_expected.to contain_concat('/home/rspec/.ssh/config').with(
      :ensure => 'present',
      :owner => 'rspec',
      :group => nil,
    ) }
  end
  context 'with group => 1000' do
    it 'group 1000' do
      params.merge!({ :group => '1000' })
      is_expected.to contain_file('/home/rspec/.ssh').with(
        :ensure => 'directory',
        :mode => '0700',
        :owner => 'rspec',
        :group => '1000',
      )
      is_expected.to contain_file('/home/rspec/.ssh/authorized_keys').with(
        :ensure => 'file',
        :mode => '0600',
        :owner => 'rspec',
        :group => '1000',
      )
      is_expected.to contain_concat('/home/rspec/.ssh/config').with(
        :ensure => 'present',
        :owner => 'rspec',
        :group => '1000',
      )
    end
  end
  context 'with group => rspec' do
    it 'group rspec' do
      params.merge!({ :group => 'rspec' })
      is_expected.to contain_file('/home/rspec/.ssh').with(
        :ensure => 'directory',
        :mode => '0700',
        :owner => 'rspec',
        :group => 'rspec',
      )
      is_expected.to contain_file('/home/rspec/.ssh/authorized_keys').with(
        :ensure => 'file',
        :mode => '0600',
        :owner => 'rspec',
        :group => 'rspec',
      )
      is_expected.to contain_concat('/home/rspec/.ssh/config').with(
        :ensure => 'present',
        :owner => 'rspec',
        :group => 'rspec',
      )
    end
  end

  it { is_expected.to contain_concat__fragment('rspec_header_ssh_config').with(
    :target => '/home/rspec/.ssh/config',
    :content => "# Managed with puppet\n",
    :order => '01',
  ) }
end
