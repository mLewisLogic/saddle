# -*- encoding: utf-8 -*-

require 'spec_helper'


describe <%= root_module %>::Middleware::ExceptionRaiser do

  describe "Test raising various exceptions using stubs" do

    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:client) { <%= root_module %>::Client.create(:stubs => stubs) }


    it 'should detect a service error' do
      stubs.get('/') { [ 500, {}, { 'status' => 'error' } ] }
      expect { client.requester.get('') }.to raise_error(<%= root_module %>::GenericException)
    end

  end

end
