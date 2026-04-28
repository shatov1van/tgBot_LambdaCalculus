module Keyboard
  def self.hotbar
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/reduce'),
          Telegram::Bot::Types::KeyboardButton.new(text: '/help')
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: '/history'),
          Telegram::Bot::Types::KeyboardButton.new(text: '/stop')
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: false
    )
  end
end