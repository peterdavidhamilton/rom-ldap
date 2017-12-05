RSpec.describe ROM::LDAP::Types do

  # describe 'ROM::LDAP::Types::Input' do
  #   it 'coerces input to strings' do
  #     klass = ROM::LDAP::Types::Input

  #     klass[nil].must_equal     ''
  #     klass['hello'].must_equal 'hello'
  #     klass[Object].must_equal  'Object'
  #     klass[:symbol].must_equal 'symbol'
  #   end
  # end

  # describe 'ROM::LDAP::Types::Entry' do
  #   it 'coerces input to array of strings' do
  #     klass  = ROM::LDAP::Types::Entry
  #     input  = [nil, 'string', :symbol, Object]
  #     output = klass[input]

  #     output.must_be_instance_of Array
  #     output.must_equal ['', 'string', 'symbol', 'Object']
  #   end
  # end

  # describe 'ROM::LDAP::Types::Jpeg' do
  #   it 'coerces binary data to base64 encoding' do
  #     klass  = ROM::LDAP::Types::Jpeg

  #     test_image = SPEC_ROOT.join('support/example.jpg')
  #     image_data = File.read(test_image)
  #     input      = [image_data]

  #     klass[input].must_equal ["data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAEAAMADASIAAhEBAxEB/8QAHAAAAgIDAQEAAAAAAAAAAAAAAAIDBAEFBgcI/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/EABsBAAIDAQEBAAAAAAAAAAAAAAMEAAECBQYH/8QAHREBAQEBAQEBAQEBAAAAAAAAAAECEQMxEmEhQf/aAAwDAQACEQMRAD8A9eTA7yHDHUyVAkYsQ7AAdWUiUofFykUWzAmcp1rG2KU1jCW9TKam5A5PPrWc8at5w6Byhnz8fv8Aq65hvE5HUz5f0K6dm9GeGNyX35f1X6fSZ3irsSW8M2u3a07YlL59/wCrlVSrCMja0iYCNi1Ex1ZMytMyGWs5RgwVDGMq+rDmFZ5+cxhuf4uOJahzZzOF9b9A0y4bxhWq7BQadI6MyVugrrCsBvKv02ztnmDZEN5T9PoB1z52dAVuE/T3QrJXB3TMRIVkjPUQpAy3IiVIrmMZypYcmvOKOYwqNC4FuXMn8ef9X1q0bcNgfx5/1OtGtt0yaxhnVcEvumYNzJLWmlQt0ogayz+mhVW5QFNYT9KS0lTF7hP0+yGCHeO9HSjLIZXmIRGsITGcqQkCE/jDLy1onKh0PPzV1bVjLTo+fmz1hcID2cK6ZAiVTEwxquqUWuUhOE9VcVlRMFrLHUp0xy+sJ1XKRQBuE6+nm7YZeC27LIDImf8AVMlO1B3zwpzrzV0TzV0fPH1mtKsoFh0vPH1i1bW1RadDGA7UxGSnM5Z6iRJUQsjGqlDAUWrIYDFjLIYAViMhgMXKPqpXWVJ8/wDbPx28ImxUl8Tyx9TZHBOpeSOh54+qc04VtmsdTzx9Cq6mCR0cZCtTJ0CU5nIdqYrDA0gdpUZyt1m0wKA7WLDAoUrhgUK4nDAoVxOPqlErLz5/rPXa+JAdzpnGWMzrnnj7qXnDo+efq6jbZrXTOn55+g1ozJAezkGsHKDEgNpwQNB2mYAVaz0oKAuicMCha+GBQtOGBQ0nH1C2SBZeFmXT3VR5i7x4wPjLXeOVaAMOl5z6HdNg2zVFdLEAumxKkKcyDdIymIKFaGSsqDp2SmYtSREGAGNGQwFxpkMBuIyGA0j64VVprHjuHZXFvKXorzAfED1XOJ0S4exANaOrrimdwBdLIANRjoAAi5QAEEkAAUvgACuMgAInQAFp0ABE6+uHOOjcM8ll0HBvPXSuOM5gemGyU21OYhfSBQbRrjuS9SAAxGQABGoAAoWAAKbAAWHQAEUAAiAAIj61eYu2eZPKeU+uk4Bz7bNcbzAtLTZKaycxC+mFNaRm8wvVcAGIyAA01AAFCwABlsABYdAAWoABEAARH0G87dm4J5jxn10649EnZO5gOkhEyqazC+jLCovGswvWtAA0ZAAW1AAGaLAAGWwAGg6AAtQACIAAiO6adba553wn1061amuoDuYDphOwlNZhfSJEnQmJC9ZKYojJCHIlagOQ7FFhzFMy2yAGw6AAtQACIAAiNqrqzLieE+unpkHTHMwHSNlMQxmF9KyFYQmJC9IUxW2SEORmtQHIcKiw5imZbZAAkDoAC1AAIgACIhWVZccnxn11NJ05Dm8wDTCIITGYX0CsmGheqpTFaZIQ5GK1AchwqLDmKZhtkACwOgALUAAiAAIgW0K253jn66WtJSJUBqQDVVkLKEaAaqysKy2LAa15TFX1khDkYq4DkOFRYcxTMcaZAAsDoAC0AARAAER//9k="]
  #   end
  # end
end
