require 'spec_helper'
require 'create_emails'
require_relative '../lib/conspire_inspire'

describe ConspireInspire do
  describe 'Current Friends' do
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

      expect(total_emails_sent).to eq({ "joe@example.com" => 3 })
    end

    it 'determines whether the most recent email received or sent by email sender has been within the last two weeks' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      recent_emails = ConspireInspire.new(data_directory).current_email_sent(email_sender)

      expect(recent_emails).to eq({ "sue@example.com"=>false, "joe@example.com"=>true })
    end

    it 'determines a senders current friends' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      current_friend = ConspireInspire.new(data_directory).determine_current_friends(email_sender)

      expect(current_friend).to eq({ "joe@example.com" => "Current Friend" })
    end

    it 'returns the number of responses to the first three emails sent by sender to recipient' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      current_active_sender = ConspireInspire.new(data_directory).current_email_respondents(email_sender)

      expect(current_active_sender).to eq({ "joe@example.com" => 2 })
    end

    it 'determines if email recipient has responded to 2/3 of sender emails' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      historical_active_sender = ConspireInspire.new(data_directory).historical_email_respondents(email_sender)

      expect(historical_active_sender).to eq({ "joe@example.com" => 0.67})
    end
  end

  describe 'Old Friends' do
    before :each do
      FileUtils.rm_rf(Dir.glob('spec/fixtures/*.eml'))
      I18n.enforce_available_locales = false

      #Sue's emails
      original_message_1 = create_email("sue@example.com", "joe@example.com", 3*7)
      original_message_2 = create_email("sue@example.com", "joe@example.com", 4*7)
      create_email("sue@example.com", "joe@example.com", 1*7*52)

      #Joe's emails
      create_email("joe@example.com", "sue@example.com", 3*7, original_message_1)
      create_email("joe@example.com", "sue@example.com", 3*7, original_message_2)
    end

    it 'determines whether the most recent email received or sent by email sender has been over two weeks ago' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      past_emails = ConspireInspire.new(data_directory).past_email_sent(email_sender)

      expect(past_emails).to eq({ "sue@example.com"=>true, "joe@example.com"=>true })
    end

    it 'determines a senders old friends' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      old_friend = ConspireInspire.new(data_directory).determine_old_friends(email_sender)

      expect(old_friend).to eq({ "joe@example.com" => "Old Friend" })
    end
  end

  describe 'Old Friends & Current Friends' do
    before :each do
      FileUtils.rm_rf(Dir.glob('spec/fixtures/*.eml'))
      I18n.enforce_available_locales = false

      #Sue's emails
      original_message_1 = create_email("sue@example.com", "joe@example.com", 3*7)
      original_message_2 = create_email("sue@example.com", "joe@example.com", 4*7)
      original_message_3 = create_email("sue@example.com", "emily@example.com", 3*7)
      original_message_4 = create_email("sue@example.com", "emily@example.com", 4*7)
      create_email("sue@example.com", "joe@example.com", 1*7*52)
      create_email("sue@example.com", "emily@example.com", 1*7*52)

      #Joe's emails
      create_email("joe@example.com", "sue@example.com", 2*7, original_message_1)
      create_email("joe@example.com", "sue@example.com", 3*7, original_message_2)

      #Emily's emails
      create_email("emily@example.com", "sue@example.com", 3*7, original_message_3)
      create_email("emily@example.com", "sue@example.com", 3*7, original_message_4)
    end

    it 'returns the senders current and old friends' do
      data_directory = 'spec/fixtures'
      email_sender = 'sue@example.com'
      old_and_current_friends = ConspireInspire.new(data_directory).determine_friend_status(email_sender)

      expect(old_and_current_friends).to eq({
          "joe@example.com" => "Current Friend",
          "emily@example.com" => "Old Friend"
        })
    end
  end
end
