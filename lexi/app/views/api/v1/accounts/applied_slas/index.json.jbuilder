json.payload do
  json.array! @applied_slas do |applied_sla|
    conversation = applied_sla.conversation
    json.applied_sla applied_sla.push_event_data
    json.conversation do
      json.id conversation.display_id
      json.status conversation.status
      json.labels conversation.cached_label_list
      json.contact do
        json.id conversation.contact&.id
        json.name conversation.contact&.name
        json.thumbnail conversation.contact&.avatar_url
      end
      if conversation.assignee
        json.assignee do
          json.id conversation.assignee.id
          json.name conversation.assignee.available_name
          json.thumbnail conversation.assignee.avatar_url
        end
      else
        json.assignee nil
      end
    end
    json.sla_events applied_sla.sla_events.map(&:push_event_data)
  end
end
json.meta do
  json.count @count
  json.current_page @current_page
end
