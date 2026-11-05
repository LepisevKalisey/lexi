# Automation action add_sla: applies the first given SLA policy of the account, unless the
# conversation already runs under one.
module Lexi::ActionService
  def add_sla(sla_policy_ids)
    return if @conversation.sla_policy_id.present?

    sla_policy = @account.sla_policies.find_by(id: Array(sla_policy_ids).first)
    return if sla_policy.nil?

    @conversation.update!(sla_policy: sla_policy)
  end
end
