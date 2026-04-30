require 'spec_helper'

RSpec.describe LyambdaGem::Reducer do
  def parse(str)
    LyambdaGem::Parser.new(str).parse
  end

  describe '.to_normal' do
    it 'редуцирует простой redex (λx.x) y' do
      term = parse('(\\x.x) y')
      result = LyambdaGem::Reducer.to_normal(term)
      expect(result.to_s).to eq('y')
    end

    it 'редуцирует несколько redex' do
      term = parse('(\\x.\\y.x y) a b')
      result = LyambdaGem::Reducer.to_normal(term)
      expect(result.to_s).to eq('(a b)')
    end

    it 'работает с конфликтом имён (альфа-конверсия)' do
      term = parse('(\\x.\\y.x y) y')
      result = LyambdaGem::Reducer.to_normal(term)
      # должно переименовать связанную y в свежую, результат примерно \z1.y z1
      expect(result.to_s).to start_with('(λz')
      expect(result.to_s).to include('y')
    end

    it 'сразу возвращает нормальную форму' do
      term = parse('x y')
      result = LyambdaGem::Reducer.to_normal(term)
      expect(result.to_s).to eq('(x y)')
    end

    it 'число Чёрча 2' do
      two = parse('\\f.\\x.f (f x)')
      succ = parse('\\n.\\f.\\x.f (n f x)')
      one = parse('\\f.\\x.f x')
      term = LyambdaGem::Application.new(succ, one)
      result = LyambdaGem::Reducer.to_normal(term)
      expect(result.to_s).to eq(two.to_s)
    end

    it 'логическое AND: true AND false = false' do
      t = parse('\\t.\\f.t')
      f = parse('\\t.\\f.f')
      andd = parse('\\p.\\q.p q p')
      term = LyambdaGem::Application.new(LyambdaGem::Application.new(andd, t), f)
      result = LyambdaGem::Reducer.to_normal(term)
      expect(result.to_s).to eq(f.to_s)
    end

    it 'редуктор не зависает и возвращает терм' do
      omega = parse('(\\x.x x) (\\x.x x)')
      result = LyambdaGem::Reducer.to_normal(omega)
      expect(result).to be_a(LyambdaGem::Term)  # любой терм
  # Дополнительно можно проверить, что он не равен исходному или что это Application
    end
  end
end