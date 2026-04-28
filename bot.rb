require 'telegram/bot'
require 'lyambda_gem'
require_relative 'keyboard'

token = '8506346847:AAFD6YrU8MwCadm2cpF_wyFCVg_8Y_vRJ20'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "Получено сообщение: #{message.text.inspect}"
    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Привет! Я бот для лямбда-исчислений.",
        reply_markup: Keyboard.hotbar
      )
    when '/evaluate'
      bot.api.send_message(chat_id: message.chat.id, text: "Введите λ-выражение:")
    when '/help'
      bot.api.send_message(chat_id: message.chat.id, text: "Справка по командам...")
    when '/history'
      bot.api.send_message(chat_id: message.chat.id, text: "История пока пуста.")
    when '/clear'
      bot.api.send_message(chat_id: message.chat.id, text: "История очищена.")
    else
      begin
        term = LyambdaGem::Parser.new(message.text).parse
        result = LyambdaGem::Reducer.to_normal(term).to_s
      rescue LyambdaGem::ParseError => e
        result = "Ошибка: #{e.message}"
      end
      bot.api.send_message(chat_id: message.chat.id, text: result)
    end
  end
end