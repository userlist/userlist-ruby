class Userlist::DeliveryMethod
  attr_reader :userlist
  attr_reader :settings

  def initialize(settings = {})
    @settings = settings

    @userlist = Userlist::Push.new(settings)
  end

  def deliver!(mail)
    message = serialize(mail)

    userlist.messages.push(message.merge(theme: nil))
  end

private

  def serialize(mail)
    {
      to: serialize_address(mail.to),
      from: serialize_address(mail.from),
      subject: mail.subject,
      body: serialize_body(mail.body)
    }.compact
  end

  def serialize_address(address)
    address.first.to_s
  end

  def serialize_body(body)
    return if body.nil?

    if body.multipart?
      parts = body.parts.filter_map { |part| serialize_part(part) }

      return parts.first if parts.size == 1

      { type: :multipart, content: parts }
    else
      { type: :text, content: body.decoded }
    end
  end

  def serialize_part(part)
    if part.content_type.start_with?('text/html')
      { type: :html, content: part.decoded }
    elsif part.content_type.start_with?('text/plain')
      { type: :text, content: part.decoded }
    end
  end
end
