# Invitations and changes of an agent's role or availability. Activity pings and automatic
# offline are not audited; neither are LEXI's custom role and capacity policy until the audit log
# screen can name them.
module Lexi::Audit::AccountUser
  extend ActiveSupport::Concern

  included do
    audited associated_with: :account, on: %i[create update],
            except: %i[active_at auto_offline custom_role_id agent_capacity_policy_id]
  end
end
