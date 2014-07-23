class ConspireInspire
  def initialize(data_directory)
    @emails_in_directory = read_files(data_directory)
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

  def determine_current_friends(email_sender)
    return_array = {}

    total_emails = total_emails_sent(email_sender)
    current_respondent = current_email_responses(email_sender)
    recent_emails = recent_email_sent

    total_emails.each do |recipient, value|
      if current_respondent[recipient] && (recent_emails[recipient] || recent_emails[email_sender])
        return_array[recipient] = "Current Friend"
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

  def recent_email_sent
    return_hash = {}

    @emails_in_directory.each do |email|
      if (Date.today - email.date).to_i <= 14
        return_hash[email.from.first] = true
      end
    end
    return_hash
  end

  def current_email_responses(email_sender)
    return_hash = {}
    reply_count = 0
    emails_sent_by_sender = @emails_in_directory.select { |email| email.from.first == email_sender }.sort.reverse
    replies_to_sender = @emails_in_directory.select { |email| (email.to.first == email_sender) && email.in_reply_to }

    emails_sent_by_sender.each do |initial_email|
      replies_to_sender.each do |reply_email|

        if return_hash[reply_email.from.first].nil?
          return_hash[reply_email.from.first] = 0
        end

        if reply_count < 3
          if initial_email.message_id == reply_email.in_reply_to
            return_hash[reply_email.from.first] += 1
          end
        end
      end
      reply_count += 1
    end
    return_hash.select { |sender, replies| replies == 2 }
  end
end
