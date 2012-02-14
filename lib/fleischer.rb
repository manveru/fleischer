require 'bacon'
require 'strscan'

module Bacon
  class Story
    attr_reader :text, :scenarios, :scanner, :indent, :name, :matches

    def initialize(text, &block)
      @text = text
      @meta = {}
      @matches = {}
      @scenarios = []

      yield self
    end

    def run
      parse
    end

    def match(regex, &block)
      @matches[regex] = block
    end

    private

    def parse
      @scanner = StringScanner.new(text)

      until scanner.eos?
        if scan(/^Story:\s+(.*)$/)
          @name = scanner[1].strip
          @indent = 1
          @story = parse_story
        elsif scan(/\s+/m)
        else
          raise scanner.inspect
        end
      end
    end

    def parse_story
      adjust_indentation
      @scenario = nil

      until @scenario
        if scan(/^#{indent}Scenario:\s+(.*)$/)
          @scenario = Scenario.new(self, scanner.matched.strip)
          parse_scenario
          @scenarios << @scenario
        elsif scan(/^#{indent}(.*?):\s+(.*)$/)
          @meta[$1] = $2
        elsif scan(/\n+/)
        else
          raise scanner.inspect
        end
      end
    end

    def parse_scenario
      adjust_indentation

      while scanner.scan(/^#{indent}/)
        if scan(/(\w.*?)$/)
          @scenario.lines << scanner.matched.strip
          scan(/\n+/)
        else
          raise scanner.inspect
        end
      end

      @scenario.run
    end


    def adjust_indentation
      scan(/^\s*/)
      @indent = scanner.matched.sub(/^\n+/, '')
      scanner.unscan
      scanner.scan(/\n+/)
    end

    def scan(regex)
      scanner.scan(regex)
    end
  end

  class Scenario
    attr_reader :name, :lines, :matches, :story

    def initialize(story, name)
      @story, @name = story, name
      @lines = []
    end

    def run
      this = self

      describe story.name do
        @self = s = this
        @story, @name, @lines = s.story, s.name, s.lines
        @matches = s.story.matches

        it @name do
          @lines.each do |line|
            if match = @matches.find{|r,b| line =~ r}
              match[1].call(*$~.captures)
            else
              raise "Unknown match: #{line}"
            end
          end
        end
      end
    end
  end
end
