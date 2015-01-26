require_relative '../spec_helper.rb'
require 'vcoworkflows'

describe VcoWorkflows::VcoSession, 'VcoSession' do

  before(:each) do
    @url = 'https://vcoserver.example.com:8281/'
    @username = 'johndoe'
    @password = 's3cr3t'
  end

  it "should set the URL" do
    vs = VcoWorkflows::VcoSession.new(@url, user: @username, password: @password)
    expect(vs.url).to eql(@url)
  end


  it "should set the username" do
    vs = VcoWorkflows::VcoSession.new(@url, user: @username, password: @password)
    expect(vs.user).to eql(@username)
  end

  it "should set the password" do
    vs = VcoWorkflows::VcoSession.new(@url, user: @username, password: @password)
    expect(vs.password).to eql(@password)
  end



end
