require 'telegram/bot'
require 'lyambda_gem'
require_relative 'keyboard'

token = '8506346847:AAFD6YrU8MwCadm2cpF_wyFCVg_8Y_vRJ20'

#Состояния пользователей
user_states = {}
@history = {}
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "Получено сообщение: #{message.text.inspect}"
    user_id = message.from.id
    current_status = user_states[user_id]
    case message.text
    when '/start'
      user_states.delete(user_id)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Привет! Я бот для лямбда-исчислений.",
        reply_markup: Keyboard.hotbar
      )
    when '/reduce'
      user_states[user_id] = :waiting_lambda
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Введите λ-выражение, которое нужно проредуцировать:"
      )
    when '/help'
      user_states.delete(user_id)
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: "Команды:\n/start - запуск бота\n/reduce - проредуцировать лямбда-выражение\n
        /help - информация о командах\n/history - история всех запросов\n/clear - очистить чат\n/stop - остановка бота")
    when '/history'
      if @history.empty?
        bot.api.send_message(chat_id: message.chat.id, text: "История пока пуста.", reply_markup: Keyboard.hotbar)
      else
        current_history = ''
        @history.each do |key, value|
          current_history += "#{key} -> #{value}\n"
        end
        bot.api.send_message(chat_id: message.chat.id, text: "История на текущий момент:\n #{current_history}", reply_markup: Keyboard.hotbar)
      end
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Работа завершена! Чтобы начать снова напишите /start!")
      user_states.delete(user_id)
      bot.stop
    else
      unless current_status == :waiting_lambda
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Нажмите (напишите) /reduce, что ввести выражение и проредуцировать его или /stop, чтобы завершить работу",
          reply_markup: Keyboard.hotbar
        )
        next
      end
      begin
        term = LyambdaGem::Parser.new(message.text).parse
        result = LyambdaGem::Reducer.to_normal(term).to_s
      rescue LyambdaGem::ParseError => e
        result = "Ошибка: #{e.message}"
      end
      @history[term] = result
      bot.api.send_message(chat_id: message.chat.id, text: "Результат редуцирования: #{result}\n\nЧто дальше?", reply_markup: Keyboard.hotbar)
    end
  end
end