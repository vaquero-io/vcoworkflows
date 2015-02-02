require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength

describe VcoWorkflows::VcoSession, 'VcoSession' do
  before(:each) do
    @uri = 'https://vcoserver.example.com:8281'
    @username = 'johndoe'
    @password = 's3cr3t'
  end

  it 'should set the URL' do
    vs = VcoWorkflows::VcoSession.new(@uri, user: @username, password: @password)
    api_url = '/vco/api'

    expect(vs.rest_resource.url).to eql(@uri << api_url)
  end

  it 'should set the username' do
    vs = VcoWorkflows::VcoSession.new(@uri, user: @username, password: @password)

    expect(vs.rest_resource.user).to eql(@username)
  end

  it 'should set the password' do
    vs = VcoWorkflows::VcoSession.new(@uri, user: @username, password: @password)

    expect(vs.rest_resource.password).to eql(@password)
  end
end

# rubocop:enable LineLength
