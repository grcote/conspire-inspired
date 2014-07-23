require 'spec_helper'
require 'create_emails'
require_relative '../lib/conspire_inspire'

describe ConspireInspire do
  before :each do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/*.eml'))
    I18n.enforce_available_locales = false

    #Sue's emails
    original_message_1 = create_email("sue@example.com", "joe@example.com", 3*7)
    original_message_2 = create_email("sue@example.com", "joe@example.com", 4*7)
    create_email("sue@example.com", "joe@example.com", 1*7*52)

    #Joe's emails
    create_email("joe@example.com", "sue@example.com", 2*7, original_message_1)
    create_email("joe@example.com", "sue@example.com", 3*7, original_message_2)
  end

  it 'totals the number of emails sent to each individual' do
    data_directory = 'spec/fixtures'
    email_sender = 'sue@example.com'
    total_emails_sent = ConspireInspire.new(data_directory).total_emails_sent(email_sender)

    expect(total_emails_sent).to eq({
                         "joe@example.com" => 3
                       })
  end

  it 'totals the number of emails responded to by the recipient' do
    data_directory = 'spec/fixtures'
    email_sender = 'sue@example.com'
    total_emails_responded_to = ConspireInspire.new(data_directory).total_email_responses(email_sender)

    expect(total_emails_responded_to).to eq({
                          "joe@example.com" => 2
                                            })
  end

  it 'determines whether the most recent email received or sent by email sender has been within the last two weeks' do
    data_directory = 'spec/fixtures'
    recent_emails = ConspireInspire.new(data_directory).recent_email_sent

    expect(recent_emails).to eq({
                          "joe@example.com" => true
                                })
  end

  it 'determines a senders current friends' do
    data_directory = 'spec/fixtures'
    email_sender = 'sue@example.com'
    current_friend = ConspireInspire.new(data_directory).determine_current_friends(email_sender)

    expect(current_friend).to eq({
                                  "joe@example.com" => "Current Friend"
                                })
  end
end


#Your code should look something like this:
#
#                                       SomeClass.new('data').relationships('joe@example.com')
#and should return a result like this:
#
#                                  {
#                                    "alice@example.com" => "Current Friend",
#                                    "ephram@example.com" => "Old Friend",
#                                    "phillis@example.com" => "Old Friend",
#                                  }
