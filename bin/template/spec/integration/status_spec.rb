# -*- encoding: utf-8 -*-

require 'spec_helper'


###
# NOTE: This spec will actually hit live servers
###

describe '<%= root_module %>::Endpoints::User' do
  context "Test integration of status endpoints" do

    let(:client) { <%= root_module %>::Client.create() }

    it 'should get self profile' do
      client.status.healthy?.should be_true
    end

  end
end
