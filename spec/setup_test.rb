# frozen_string_literal: true

require 'rspec'
require 'support/setup'

describe Setup do
  it 'passes' do
    expect(Setup.new.check).to eq true
  end
end
