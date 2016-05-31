# Pagetience
[![Build Status](https://travis-ci.org/dmcneil/pagetience.svg?branch=master)](https://travis-ci.org/dmcneil/pagetience)

Pronounced like "patience".

Using a simple DSL, you can declare which of your page object elements must be present and visible on the page before your code can consider it **loaded**.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pagetience'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pagetience

## Usage
To use **Pagetience**, simply `include Pagetience` in your page object class and then use the `required` method to set which elements must be visible on the page for it to be considered loaded.

```ruby
class GooglePage
  include PageObject
  include Pagetience

  text_field :search, name: 'q'
  required :search
end
```

When an instance of your page object is created then the required elements will be checked for.

#### Page transitions
Using the `wait_for_transition_to` method within your page object, you can now wait for an expected page to transition to.

```ruby
class FirstPage
  include PageObject
  include Pagetience

  text_field :a, id: 'a'
  button :b, id: 'b'
  required :a, :b

  def go_to_b
    self.a = 'a'
    self.b

    wait_for_transition_to SecondPage
  end
end

class SecondPage
  include PageObject
  include Pagetience

  button :c, id: 'c'
  required :c

  def back_to_a
    self.c

    wait_for_transition_to FirstPage, 15, 5 # wait up to 15 seconds, polling every 5 seconds
  end
end

# In a test

@current_page = FirstPage.new(@browser).go_to_b
expect(@current_page.loaded?).to eq true # true
expect(@current_page).to be_an_instance_of SecondPage # true
```

#### Waiting for individual elements
The `wait_for_element` method allows you to wait for a specific element on the page to be there. It doesn't have to be one of your `required` fields -- it just has to declared.

```ruby
class SomePage
  include PageObject
  include Pagetience

  button :foo, id: 'foo'

  def wait_for_foo
    wait_for_element :foo
  end

  def wait_longer_for_foo
    wait_for_element :foo, 60, 5 # wait up to 60 seconds, polling every 5 seconds
  end
end
```

## Configuration
Pagetience can be configured, too.

```ruby
Pagetience.configure do |config|
  config.timeout = 60
  config.polling = 5
end
```

It can then be retrieve easily!

```ruby
def give_me_a_property
  Pagetience.config.timeout
end

give_me_a_property # => 60
````

#### Adjusting the Timeout/Polling for a specific Page
You can use the `waiting` method to specify how long you want to wait and, optionally, at what interval to poll the page for element visibility.

The default timeout is **30** seconds, polling every second.

```ruby
class GooglePage
  include PageObject
  include Pagetience

  text_field :search, name: 'q'
  required :search
  waiting 60, 5 # wait up to 60 seconds, polling every 5 seconds
end
```

## Supported Platforms
Currently, this gem only works with the [page-object](https://github.com/cheezy/page-object) gem. It's a high priority to make working with other page object/webdriver libraries easier.

## Notes/Todo/Issues
1. Add platform support for Selenium WebDriver
2. Add platform support for Watir WebDriver
3. SitePrism?
4. Documentation
5. Organize unit tests

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/dmcneil/pagetience.


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

