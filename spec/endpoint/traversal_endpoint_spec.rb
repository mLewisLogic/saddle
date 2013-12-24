require 'spec_helper'

describe Saddle::TraversalEndpoint do
  it 'can build and attach nodes' do
    class TestEndpoint < Saddle::TraversalEndpoint; end
    expect {
      TestEndpoint.new(Saddle::Client.create)._build_and_attach_node(Saddle::TraversalEndpoint)
      }.to_not raise_error
  end
end
