require 'bundler/setup'
Bundler.require(:default)
require 'telegram/bot'
require 'lyambda_gem'
require 'dotenv/load'
require_relative 'keyboard'

token = ENV['TELEGRAM_BOT_TOKEN']

#Состояния пользователей
user_states = {}
@history = {}
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "Получено сообщение: #{message.text.inspect}"
    user_id = message.from.id
    current_status = user_states[user_id]
    @history[user_id] ||= {} #инициализировали хэш для хранения истории конкретного юзера
    case message.text
    when '/start'
      user_states.delete(user_id)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Привет! Я бот для редуцирования лямбда-исчислений. Нажмите /reduce и напишите терм для редуцирования.",
        reply_markup: Keyboard.hotbar
      )
    when '/reduce'
      user_states[user_id] = :waiting_lambda
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Введите λ-выражение, которое нужно проредуцировать:"
      )
    when '/help'
      user_states[user_id] = nil
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: "Команды:\n/info - подробная информация о боте\n/reduce - проредуцировать лямбда-выражение\n/help - информация о командах\n/history - история всех решений\n/reset - сброс истории",
        reply_markup: Keyboard.hotbar)
    when '/history'
      user_states[user_id] = nil
      if @history[user_id].empty?
        bot.api.send_message(chat_id: message.chat.id, text: "История пока пуста.", reply_markup: Keyboard.hotbar)
      else
        current_history = ''
        @history[user_id].each do |key, value|
          current_history += "(Запрос/Ответ) #{key} -> #{value}\n\n"
        end
        bot.api.send_message(chat_id: message.chat.id, text: "История на текущий момент:\n#{current_history}", reply_markup: Keyboard.hotbar)
      end
    when '/reset'
      bot.api.send_message(chat_id: message.chat.id, text: "История очищена!", reply_markup: Keyboard.hotbar)
      user_states[user_id] = nil
      @history[user_id] = nil
    when '/info'
      user_states[user_id] = nil
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: "Это бот LambdaCalculus, он предназначен для редуцирования лямбда-выражений.
        Главная команда это /reduce, после нее нужно вводить термы и вы получите результат.
        История ваших запросов/ответов сохраняется, чтобы ее увидеть нужно нажать на /history.
        Команда /reset очистит вашу историю. Бот максимально прост в использовании.",
        reply_markup: Keyboard.hotbar)
    else
      #Обработка некорреткного ввода
      unless current_status == :waiting_lambda
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Я не понимаю ваш запрос, нажмите /help!",
          reply_markup: Keyboard.hotbar
        )
        next
      end
      begin
        #Здесь парсинг лямбда выражений
        term = LyambdaGem::Parser.new(message.text).parse
        result = LyambdaGem::Reducer.to_normal(term).to_s
      rescue LyambdaGem::ParseError => e
        result = "Ошибка: #{e.message}.\nВозможно вы не правильно ввели терм."
      end
      #Запись ответа в историю
      @history[user_id][term] = result
      bot.api.send_message(chat_id: message.chat.id, text: "Результат редуцирования: #{result}\n\nНапишите новый терм для редуцирования или /help", reply_markup: Keyboard.hotbar)
    end
  end
end