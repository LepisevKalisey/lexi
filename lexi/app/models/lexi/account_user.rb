# An agent with a custom role works with the role's permissions instead of the agent role.
# The dashboard reads them from the user's account payload.
module Lexi::AccountUser
  def permissions
    return super if administrator? || custom_role.nil?

    [*custom_role.permissions, 'custom_role']
  end
end
