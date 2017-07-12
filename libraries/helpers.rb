module Tools
  require 'net/smtp'
  require 'json'
  require 'net/http'

  def self.get_ips(node_name, file_path)
    file = File.read(file_path)
    hash = JSON.parse(file)
    return hash[node_name]
  end


  def self.fetch(url)
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    return JSON.parse(data)
  end

  def self.unindent string
    first = string[/\A\s*/]
    string.gsub /^#{first}/, ''
  end

  def self.simple_email(to, opts={})
    opts[:server]      ||= 'smtp.office365.com'
    opts[:port]        ||= 587
    opts[:from]        ||= 'barcoder@redsis.com'
    opts[:password]    ||= 'Orion2015'
    opts[:from_alias]  ||= 'Chef Reporter'
    opts[:subject]     ||= "Chef Start on Node #{Chef.run_context.node.name}"
    opts[:message]     ||= "..."

    message = <<-MESSAGE
      From: #{opts[:from_alias]} <#{opts[:from]}>
      To: <#{to}>
      Subject: #{opts[:subject]}

      #{opts[:message]}
    MESSAGE

    mailtext = unindent message

    smtp = Net::SMTP.new(opts[:server], opts[:port])
    smtp.enable_starttls_auto
    smtp.start(opts[:server], opts[:from], opts[:password], :login)
    smtp.send_message(mailtext, opts[:from], to)
    smtp.finish
  end

end

Chef::Recipe.send(:include, Tools)
