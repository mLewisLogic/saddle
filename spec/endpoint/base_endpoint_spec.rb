require 'spec_helper'

describe Saddle::BaseEndpoint do
  let(:base_endpoint) { Saddle::BaseEndpoint.new(Saddle::Client.create) }

  it 'can define singleton methods' do
    expect(base_endpoint.respond_to?(:define_singleton_method)).to be_truthy
  end

  it 'responds to any defined singleton methods' do
    base_endpoint.define_singleton_method(:my_method) { true }
    expect(base_endpoint.my_method).to be_truthy
  end
end
