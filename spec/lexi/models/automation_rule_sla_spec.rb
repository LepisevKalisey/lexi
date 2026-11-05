require 'rails_helper'

RSpec.describe AutomationRule do
  it 'accepts the add_sla action' do
    rule = build(:automation_rule, actions: [{ 'action_name' => 'add_sla', 'action_params' => [1] }])

    expect(rule).to be_valid
  end
end
