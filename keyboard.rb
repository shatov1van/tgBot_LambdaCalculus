module Keyboard
  def self.hotbar
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/evaluate'),
          Telegram::Bot::Types::KeyboardButton.new(text: '/help')
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/history'),
          Telegram::Bot::Types::KeyboardButton.new(text: '/clear')
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: false
    )
  end
end