RSpec.describe ROM::LDAP::Types do

  describe 'Address' do
    subject(:type) { ROM::LDAP::Types::Address }

    it 'foo' do
      expect(type['street$town$region$country']).to eq(%w[street town region country])
    end

    xit 'ignores other values' do
      expect(type[nil]).to be_nil
      expect(type['string']).to eql('string')
      expect(type[Object]).to eql(Object)
      expect(type[:symbol]).to eql(:symbol)
      expect(type[123]).to eql(123)
    end
  end

  describe 'Time' do
    subject(:type) { ROM::LDAP::Types::Time }

    it 'ignores nil values' do
      expect(type[nil]).to be_nil
    end

    # oid:1.3.6.1.4.1.1466.115.121.1.24
    it 'coerces GeneralizedTime' do
      expect(type['20181109175836.147Z'].to_s).to eq('2018-11-09 17:58:36 UTC')
      expect(type['20020514230000Z'].to_s).to eq('2002-05-14 23:00:00 UTC')
    end

    it 'coerces Active Directory timestamps' do
      expect(type['131862601330000000'].to_s).to eq('2018-11-09 18:02:13 +0000')
      expect(type[0].to_s).to eql('1601-01-01 01:00:00 +0100')
    end

    it 'raises errors with invalid values' do
      expect { type['string'] }.to raise_error(ArgumentError, 'no time information in "string"')
      expect { type[Object] }.to raise_error(TypeError, "can't convert Class into Integer")
      expect { type[:symbol] }.to raise_error(TypeError, "can't convert Symbol into Integer")
    end
  end


  describe 'Bool' do
    subject(:type) { ROM::LDAP::Types::Bool }

    it 'coerces true values' do
      expect(type['t']).to be(true)
      expect(type['TRUE']).to be(true)
      expect(type['y']).to be(true)
      expect(type['yes']).to be(true)
    end

    it 'coerces false values' do
      expect(type['f']).to be(false)
      expect(type['FALSE']).to be(false)
      expect(type['n']).to be(false)
      expect(type['no']).to be(false)
    end

    it 'ignores other values' do
      expect(type[nil]).to be_nil
      expect(type['string']).to eql('string')
      expect(type[Object]).to eql(Object)
      expect(type[:symbol]).to eql(:symbol)
      expect(type[123]).to eql(123)
    end
  end

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
