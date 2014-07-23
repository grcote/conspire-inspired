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
    total_responses = total_email_responses(email_sender)
    recent_emails = recent_email_sent

    total_emails.each do |recipient,value|
      if total_responses[recipient] && (recent_emails[recipient] || recent_emails[email_sender])
        return_array[recipient] = "Current Friend"
      end
    end

    return_array
  end








  def total_emails_sent(email_sender)
    return_hash = {}
    emails_sent_by_sender = @emails_in_directory
    emails_sent_by_sender = emails_sent_by_sender.select { |email| email.from.first == email_sender }

    emails_sent_by_sender.each do |email|
      if return_hash[email.to.first].nil?
        return_hash[email.to.first] = 1
      else
        return_hash[email.to.first] += 1
      end
    end
    return_hash.select { |recipient, emails_received| emails_received >= 3 }
  end



  def total_email_responses(email_sender)
    return_hash = {}

    @emails_in_directory.each do |email|
      if (email.in_reply_to) && (email.to.first == email_sender)
        if return_hash[email.from.first].nil?
          return_hash[email.from.first] = 1
        else
          return_hash[email.from.first] += 1
        end
      end
    end
    return_hash.select { |sender, emails_sent| emails_sent >= 2 }
  end

  #need a method that returns a name and true if they've responded to the last three emails


  def recent_email_sent
    return_hash = {}

    @emails_in_directory.each do |email|
      if (Date.today - email.date).to_i <= 14
        return_hash[email.from.first] = true
      end
    end
    return_hash
  end
end

#Joe has replied to 2 out of the last 3 emails

