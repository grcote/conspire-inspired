require 'mail'
require 'faker'
require 'securerandom'

def create_email(sender, recipient, days_ago, in_reply_to = nil)
  id = SecureRandom.uuid
  message = Mail.new do
    in_reply_to in_reply_to if in_reply_to
    to recipient
    from sender
    date Date.today - days_ago
    subject Faker::Lorem.sentence
    body Faker::Lorem.paragraphs.join("\n\n")
    message_id "<#{id}@example.com>"
  end
  File.open("spec/fixtures/#{id}.eml", "w") { |f| f.puts message.to_s }
  message.message_id
end