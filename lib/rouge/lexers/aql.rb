# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class AQL < RegexLexer
      tag 'aql'
      #filenames '*.aql'
      #mimetypes 'text/x-aql'

      title 'AQL'
      desc 'ArangoDB Query Language'

      state :multiline_comment do
        rule %r([*]/), Comment::Multiline, :pop!
        rule %r([^*/]+), Comment::Multiline
        rule %r([*/]), Comment::Multiline
      end

      state :comments_and_whitespace do
        rule %r/\s+/, Text
        rule %r/<!--/, Comment # really...?
        rule %r(//.*?$), Comment::Single
        rule %r(/[*]), Comment::Multiline, :multiline_comment
      end

      def self.keywords
        @keywords ||= Set.new %w(
          AGGREGATE ALL AND ANY ASC COLLECT DESC DISTINCT FILTER FOR GRAPH IN
          INBOUND INSERT INTO K_SHORTEST_PATHS LET LIKE LIMIT NONE NOT OR
          OUTBOUND REMOVE REPLACE RETURN SHORTEST_PATH SORT UPDATE UPSERT WITH
        )
      end

      def self.constants
        @constants ||= Set.new %w(TRUE FALSE NULL)
      end

      # pseudo-keyword combination
      # WITH COUNT INTO

      # pseudo-keywords, case insensitive
      # KEEP PRUNE SEARCH TO

      # pseudo-varaibles, case sensitive
      # CURRENT NEW OLD

      # pseudo-keyword
      # OPTIONS {...}

      state :root do
        rule %r((?<=\n)(?=\s|/|<!--)), Text, :expr_start
        mixin :comments_and_whitespace
        rule %r(\*{2,} | [=!]~ | [!=<>]=? | && | \|\| | [-+*/%] )x,
          Operator, :expr_start
        rule %r/[(\[{]/, Punctuation, :expr_start
        rule %r/[)\]}]/, Punctuation

        rule %r/`/ do
          token Str::Double
          push :template_string
        end

        rule %r/[?]/ do
          token Punctuation
          push :ternary
          push :expr_start
        end

        rule %r/\@\@?\w+/ do # TODO variable
          groups Punctuation, Name::Decorator
          push :expr_start
        end

        rule %r/[{}]/, Punctuation, :statement

        rule id do |m|
          if self.class.keywords.include? m[0]
            token Keyword
            push :expr_start
          elsif self.class.declarations.include? m[0]
            token Keyword::Declaration
            push :expr_start
          elsif self.class.reserved.include? m[0]
            token Keyword::Reserved
          elsif self.class.constants.include? m[0]
            token Keyword::Constant
          elsif self.class.builtins.include? m[0]
            token Name::Builtin
          else
            token Name::Other
          end
        end

        rule %r/(\B\.\d+|\b(0|[1-9]\d*)(\.\d+)?)(e[+-]?\d+)?/i, Num

        rule %r/"/, Str::Delimiter, :dq
        rule %r/'/, Str::Delimiter, :sq
        rule %r/:/, Punctuation
      end

      state :dq do
        rule %r/\\[\\nrt"]?/, Str::Escape
        rule %r/[^\\"]+/, Str::Double
        rule %r/"/, Str::Delimiter, :pop!
      end

      state :sq do
        rule %r/\\[\\nrt']?/, Str::Escape
        rule %r/[^\\']+/, Str::Single
        rule %r/'/, Str::Delimiter, :pop!
      end

    end
  end
end
