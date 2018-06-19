Given(/^the endpoint "([^"]*)" returns this content:$/) do |path, input|
  RubyMock.resources[path] = input
end

Then(/^the following request body should have been sent:$/) do |string|
  RubyMock.requests.map {|n| JSON.parse(n) }.should include(JSON.parse string)
end

Given("the endpoint {string} returns {string}") do |string, string2|
	RubyMock.resources[string] = File.read("features/fixtures/#{string2}")
end
