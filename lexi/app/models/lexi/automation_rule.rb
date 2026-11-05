module Lexi::AutomationRule
  def actions_attributes
    [*super, 'add_sla'].freeze
  end
end
