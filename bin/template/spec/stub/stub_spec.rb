# -*- encoding: utf-8 -*-

require 'spec_helper'



describe <%= root_module %>::Stub do
  context 'stubbing out calls' do

    let(:client) { <%= root_module %>::Client.create }

    before :each do
      <%= root_module %>::Client.stub!
    end

    describe 'returns test data' do
      it 'for client.status.healthy?' do
        client.status.healthy?.should be_true
      end
    end

  end
end
