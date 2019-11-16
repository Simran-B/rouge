# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::AQL do
  let(:subject) { Rouge::Lexers::AQL.new }

  describe 'lexing' do
    include Support::Lexing

    # TODO

    #it %(doesn't let a bad regex mess up the whole lex) do
    #  assert_has_token 'Error',          "var a = /foo;\n1"
    #  assert_has_token 'Literal.Number', "var a = /foo;\n1"
    #end
  end

  describe 'guessing' do
    include Support::Guessing

    #it 'guesses by filename' do
    #  assert_guess :filename => 'foo.aql'
    #end

    #it 'guesses by mimetype' do
    #  assert_guess :mimetype => 'text/aql'
    #end

  end
end
