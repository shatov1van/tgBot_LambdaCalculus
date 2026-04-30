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
          Telegram::Bot::Types::KeyboardButton.new(text: '/reset')
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: false
    )
  end
  def self.reduction_mode_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [
          Telegram::Bot::Types::KeyboardButton.new(text: 'Обычная редукция'),
          Telegram::Bot::Types::KeyboardButton.new(text: 'Пошаговая редукция')
        ],
        [
          Telegram::Bot::Types::KeyboardButton.new(text: 'Отмена')
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    )
  end
end