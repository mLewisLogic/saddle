require 'spec_helper'

describe Saddle::BaseEndpoint do
  it 'can define singleton methods' do
    expect(Saddle::BaseEndpoint.respond_to?(:define_singleton_method)).to be_true
  end

  it 'responds to any defined singleton methods' do
    Saddle::BaseEndpoint.define_singleton_method(:my_method) { true }
    expect(Saddle::BaseEndpoint.my_method).to be_true
  end
end