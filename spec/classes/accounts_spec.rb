require 'spec_helper'

describe 'accounts', :type => :class do
  let(:facts) {{ :concat_basedir => '/tmp', }}
  context 'with manage_groups => true' do
    let(:params) { {:manage_groups => true, } }
    
    it 'should create a group if given' do
      params.merge!({:managed_groups => { 'foo' => { 'gid' => '1000' } } })
      should contain_group('foo').with({'gid' => '1000'})
    end  
  end
  context 'with manage_users => true' do
    let(:params) { {:manage_users => true, } }

    it 'should create accounts::user if managed_users is set' do
      params.merge!({:managed_users => { 'bar' => { } } })
      is_expected.to contain_accounts__user('bar')
    end
    it 'should create accounts::usergroup if managed_usergroups array is set' do
      params.merge!({:managed_usergroups => [ 'bar', ] })
      is_expected.to contain_accounts__usergroup('bar')
    end
    it 'should create accounts::usergroup if managed_usergroups hash is set' do
      params.merge!({:managed_usergroups => { 'bar' => { } } })
      is_expected.to contain_accounts__usergroup('bar')
    end
  end
#  context 'with manage_sudoers => true' do
#    let(:params) { { :manage_sudoers => true } }
#    
#    it 'should contain class sudo' do
#      is_expected.to contain_class('sudo')
#    end
#  end
end
