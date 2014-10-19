class EventParser
  XML_NS = {
    "cv" => "http://openhbx.org/api/terms/1.0"
  }

  SPECIAL_HEADERS = [
:persistent,
:mandatory,
:timestamp,
:expiration,
:type,
:reply_to,
:content_type,
:content_encoding,
:correlation_id,
:priority,
:message_id,
:user_id,
:app_id
  ].map(&:to_s)

  EXCLUDED_KEYS = [
   :routing_key,
   :body
  ].map(&:to_s)

  def initialize(e_doc)
    @event = e_doc
  end

  def event_uri
    @event.xpath("//cv:event/cv:event_name", XML_NS).first.text
  end

  def message_body
  end

  def message_headers
    mesg_headers = {:headers => {}}
    set_headers_from(@event.xpath("//cv:event", XML_NS), mesg_headers)
    set_headers_from(@event.xpath("//cv:header", XML_NS), mesg_headers)
    mesg_headers
  end

  def set_headers_from(parent_node, headers)
    parent_node.children.each do |node|
      if include_in_headers?(node)
        if SPECIAL_HEADERS.include?(node.name.strip)
          headers[node.name] = node.text
        else
          headers[:headers][node.name] = node.text
        end
      end
    end
  end

  def message_body
    body_node = @event.xpath("//cv:event/cv:body", XML_NS).first
    return nil unless body_node
    body_root_node = body_node.children.detect { |cn| cn.element? }
    return nil unless body_root_node
    body_root_node.canonicalize
  end

  def include_in_headers?(node)
    return false unless node.element?
    !EXCLUDED_KEYS.include?(node.name)
  end

  def self.parse(event)
    self.new(event)
  end
end
