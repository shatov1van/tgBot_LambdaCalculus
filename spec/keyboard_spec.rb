require 'spec_helper'
require_relative '../keyboard'

RSpec.describe Keyboard do
  it 'возвращает ReplyKeyboardMarkup с 4 кнопками' do
    kb = Keyboard.hotbar
    expect(kb).to be_a(Telegram::Bot::Types::ReplyKeyboardMarkup)
    expect(kb.keyboard.flatten.size).to eq(4)
  end
end