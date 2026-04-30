require 'bundler/setup'
Bundler.require(:default)
require 'telegram/bot'
require 'lyambda_gem'
require 'dotenv/load'
require_relative 'keyboard'

token = ENV['TELEGRAM_BOT_TOKEN']

# Состояния пользователей: может быть :waiting_lambda, :waiting_reduction_mode
user_states = {}
@history = {}

# Вспомогательная функция для пошаговой редукции с отправкой каждого шага в чат
def step_by_step_reduction(term, bot, chat_id)
  step = 0
  answer = "##{step} `#{term}`"
  
  
  while term.reduceable?
    term = term.reduce(strategy: :normal_order)
    step += 1
    answer += "##{step} `#{term}`\n"
    if step > 99
      bot.api.send_message(chat_id: chat_id, text: "Редукция не завершилась за 99 шагов, возможно бесконечный цикл. Прерывание.")
      break
    end
  end
  bot.api.send_message(chat_id: chat_id, text: answer)
  term
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "Получено сообщение: #{message.text.inspect}"
    user_id = message.from.id
    current_status = user_states[user_id]
    @history[user_id] ||= {} # инициализация истории для пользователя

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
        reply_markup: Keyboard.hotbar
      )
    when '/history'
      user_states[user_id] = nil
      if @history[user_id].empty?
        bot.api.send_message(chat_id: message.chat.id, text: "История пока пуста.", reply_markup: Keyboard.hotbar)
      else
        current_history = ''
        @history[user_id].each do |key, value|
          current_history += "(Запрос/Ответ) `#{key}` -> `#{value}`\n\n"
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
        text: "Это бот LambdaCalculus, он предназначен для редуцирования лямбда-выражений.\nГлавная команда это /reduce, после нее нужно вводить термы и вы получите результат.\nИстория ваших запросов/ответов сохраняется, чтобы ее увидеть нужно нажать на /history.\nКоманда /reset очистит вашу историю. Бот максимально прост в использовании.",
        reply_markup: Keyboard.hotbar
      )
    else
      # Обработка состояний
      case current_status
      when :waiting_lambda
        # Пользователь ввёл терм для редукции
        begin
          input_text = message.text
          term = LyambdaGem::Parser.new(input_text).parse
          # Сохраняем терм и исходную строку в состоянии, переходим к выбору режима
          user_states[user_id] = { state: :waiting_reduction_mode, term: term, input_text: input_text }
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Выберите режим редукции:",
            reply_markup: Keyboard.reduction_mode_keyboard
          )
        rescue LyambdaGem::ParseError => e
          result = "Ошибка: #{e.message}.\nВозможно вы не правильно ввели терм."
          bot.api.send_message(chat_id: message.chat.id, text: result, reply_markup: Keyboard.hotbar)
          # Оставляем состояние :waiting_lambda, чтобы можно было повторить ввод
        end
      when Hash
        # Ожидание выбора режима редукции
        if current_status[:state] == :waiting_reduction_mode
          case message.text
          when 'Обычная редукция'
            term = current_status[:term]
            input_text = current_status[:input_text]
            result = LyambdaGem::Reducer.to_normal(term, verbose: false).to_s
            # Сохраняем в историю
            @history[user_id][input_text] = result
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "Результат редукции: #{result}\n\nНапишите новый терм для редуцирования или /help",
              reply_markup: Keyboard.hotbar
            )
            user_states.delete(user_id)
          when 'Пошаговая редукция'
            term = current_status[:term]
            input_text = current_status[:input_text]
            # Выполняем пошаговую редукцию
            final_term = step_by_step_reduction(term, bot, message.chat.id)
            result = final_term.to_s
            @history[user_id][input_text] = result
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "Редукция завершена. Конечный результат: #{result}\n\nНапишите новый терм для редуцирования или /help",
              reply_markup: Keyboard.hotbar
            )
            user_states.delete(user_id)
          when 'Отмена'
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "Редукция отменена. Нажмите /reduce, чтобы начать заново.",
              reply_markup: Keyboard.hotbar
            )
            user_states.delete(user_id)
          else
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "Пожалуйста, выберите режим, используя кнопки ниже.",
              reply_markup: Keyboard.reduction_mode_keyboard
            )
          end
        else
          # Неизвестное состояние – сброс
          user_states.delete(user_id)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Я не понимаю ваш запрос, нажмите /help!",
            reply_markup: Keyboard.hotbar
          )
        end
      else
        # Нет активного состояния – неизвестная команда
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Я не понимаю ваш запрос, нажмите /help!",
          reply_markup: Keyboard.hotbar
        )
      end
    end
  end
end