module Keyboard
  def self.hotbar
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        ['/evaluate', '/help'],
        ['/history', '/clear']
      ],
      resize_keyboard: true,
      one_time_keyboard: false
    )
  end
end