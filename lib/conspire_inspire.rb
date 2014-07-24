class ConspireInspire
  def initialize(data_directory)
    @emails_in_directory = read_files(data_directory)
  end

  def return_data
    @emails_in_directory
  end

  def read_files(data_directory)
    return_array = []

    Dir.foreach(data_directory) do |file|
      file_path = "#{data_directory}/#{file}"
      if file.include?('.eml')
        mail = Mail.read(file_path)
        return_array << mail
      end
    end
    return_array
  end

  def determine_friend_status(email_sender)
    return_array = {}
      current_friends = determine_current_friends(email_sender)
      old_friends = determine_old_friends(email_sender)
    return_array.merge(current_friends).merge(old_friends)
  end

  def determine_current_friends(email_sender)
    return_array = {}

    total_emails = total_emails_sent(email_sender)
    current_respondents = current_email_respondents(email_sender)
    current_emails = current_email_sent(email_sender)

    total_emails.each do |recipient, value|
      if current_emails[recipient] || current_emails[email_sender]
        if current_respondents[recipient] && current_emails[recipient]
          return_array[recipient] = "Current Friend"
        end
      end
    end
    return_array
  end

  def determine_old_friends(email_sender)
    return_array = {}

    total_emails = total_emails_sent(email_sender)
    historical_respondents = historical_email_respondents(email_sender)
    past_emails = past_email_sent(email_sender)

    total_emails.each do |recipient, value|

      if past_emails[recipient] || past_emails[email_sender]
        if historical_respondents[recipient] && past_emails[recipient]
        return_array[recipient] = "Old Friend"
        end
      end
    end
    return_array
  end

  def total_emails_sent(email_sender)
    return_hash = {}
    emails_sent_by_sender = @emails_in_directory.select { |email| email.from.first == email_sender }

    emails_sent_by_sender.each do |email|
      if return_hash[email.to.first].nil?
        return_hash[email.to.first] = 1
      else
        return_hash[email.to.first] += 1
      end
    end
    return_hash.select { |recipient, emails_received| emails_received >= 3 }
  end

  def current_email_sent(email_sender)
    return_hash = {}
    emails_involving_sender = @emails_in_directory.select { |email| email.from.first == email_sender || email.to.first == email_sender }.sort

    emails_involving_sender.each do |email|
      if (Date.today - email.date).to_i <= 14
        return_hash[email.from.first] = true
      else
        return_hash[email.from.first] = false
      end
    end
    return_hash
  end

  def past_email_sent(email_sender)
    return_hash = {}
    emails_involving_sender = @emails_in_directory.select { |email| email.from.first == email_sender || email.to.first == email_sender }.sort

    emails_involving_sender.each do |email|
      if (Date.today - email.date).to_i > 14
        return_hash[email.from.first] = true
      else
        return_hash[email.from.first] = false
      end
    end
    return_hash
  end

  def current_email_respondents(email_sender)
    return_hash = {}
    reply_receipt_count = {}
    emails_sent_by_sender = @emails_in_directory.select { |email| email.from.first == email_sender }.sort.reverse
    replies_to_sender = @emails_in_directory.select { |email| (email.to.first == email_sender) && email.in_reply_to }

    emails_sent_by_sender.each do |initial_email|
      replies_to_sender.each do |reply_email|

        if reply_receipt_count[reply_email.from.first].nil?
          reply_receipt_count[reply_email.from.first] = {:replies => 0, :receipts => 0}
        end

        if reply_receipt_count[reply_email.from.first][:receipts] < 3
          if initial_email.message_id == reply_email.in_reply_to
            reply_receipt_count[reply_email.from.first][:replies] += 1
          end
        end
      end
      reply_receipt_count[initial_email.to.first][:receipts] += 1
    end
    reply_receipt_count.each do |message_replier, replies_receipts|
      return_hash[message_replier] = replies_receipts[:replies]
    end

    return_hash.select { |sender, replies| replies == 2 }
  end

  def historical_email_respondents(email_sender)
    return_hash = {}
    reply_receipt_count = {}
    emails_sent_by_sender = @emails_in_directory.select { |email| email.from.first == email_sender }.sort
    replies_to_sender = @emails_in_directory.select { |email| (email.to.first == email_sender) && email.in_reply_to }

    emails_sent_by_sender.each do |initial_email|
      replies_to_sender.each do |reply_email|

        if reply_receipt_count[reply_email.from.first].nil?
          reply_receipt_count[reply_email.from.first] = {:replies => 0, :receipts => 0}
        end

        if initial_email.message_id == reply_email.in_reply_to
          reply_receipt_count[reply_email.from.first][:replies] += 1
        end
      end
      reply_receipt_count[initial_email.to.first][:receipts] += 1
    end

    reply_receipt_count.each do |message_replier,replies_receipts|
      return_hash[message_replier] = (replies_receipts[:replies].to_f/replies_receipts[:receipts].to_f).round(2)
    end

    return_hash.select { |sender, response_rate| response_rate >= 0.67}
  end
end
