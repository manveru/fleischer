require_relative '../lib/fleischer'

Bacon.summary_on_exit

text = <<TEXT
Story: Publish speakers
  As a: conference organizer
  I want to: publish the list of speakers
  So that: as many people as possible will come

  Scenario: 2 new speakers
    Given an presentation without speakers
    When I add 2 speakers
    Then I should see 2 speakers
TEXT

Bacon::Story.new(text) do |story|
  story.match(/Given an presentation without speakers/) do
    @presentation = []
  end

  story.match(/When I add (\d+) speakers/) do |n|
    @presentation += Array.new(n.to_i, :speaker)
  end

  story.match(/Then I should see (\d+) speakers/) do |n|
    @presentation.size.should == n.to_i
  end

  story.run
end
