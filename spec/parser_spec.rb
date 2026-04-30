require 'spec_helper'

RSpec.describe LyambdaGem::Parser do
  describe '#parse' do
    it 'парсит переменную' do
      term = LyambdaGem::Parser.new('x').parse
      expect(term).to be_a(LyambdaGem::Variable)
      expect(term.name).to eq('x')
    end

    it 'парсит абстракцию с одним параметром' do
      term = LyambdaGem::Parser.new('\\x.x').parse
      expect(term).to be_a(LyambdaGem::Abstraction)
      expect(term.parameter.name).to eq('x')
      expect(term.body).to be_a(LyambdaGem::Variable)
      expect(term.body.name).to eq('x')
    end

    it 'парсит применение двух переменных' do
      term = LyambdaGem::Parser.new('x y').parse
      expect(term).to be_a(LyambdaGem::Application)
      expect(term.left).to be_a(LyambdaGem::Variable)
      expect(term.right).to be_a(LyambdaGem::Variable)
    end

    it 'парсит вложенные абстракции' do
      term = LyambdaGem::Parser.new('\\x.\\y.x y').parse
      expect(term).to be_a(LyambdaGem::Abstraction)
      expect(term.body).to be_a(LyambdaGem::Abstraction)
      expect(term.body.body).to be_a(LyambdaGem::Application)
    end

    it 'парсит скобки для группировки' do
      term = LyambdaGem::Parser.new('(\\x.x) y').parse
      expect(term).to be_a(LyambdaGem::Application)
      expect(term.left).to be_a(LyambdaGem::Abstraction)
      expect(term.right).to be_a(LyambdaGem::Variable)
    end

    it 'поддерживает λ вместо \\' do
      term = LyambdaGem::Parser.new('λx.x').parse
      expect(term.to_s).to eq('(λx.x)')
    end

    it 'выбрасывает ParseError на невалидный ввод' do
      expect { LyambdaGem::Parser.new('\\x.').parse }.to raise_error(LyambdaGem::ParseError)
    end

    it 'выбрасывает ошибку при непарной скобке' do
      expect { LyambdaGem::Parser.new('(\\x.x').parse }.to raise_error(LyambdaGem::ParseError)
    end
  end
end