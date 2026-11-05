json.payload do
  json.partial! 'api/v1/models/sla_policy', sla_policy: @sla_policy
end
