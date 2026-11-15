# frozen_string_literal: true

# Account features that LEXI adds on top of config/features.yml (L-018). They behave like
# the other feature flags: in all_features and the account payload, in the super admin
# checkboxes, with feature_<name>? and feature_<name>=. They are kept in accounts.settings,
# not in a flag bit: a bit is a position in config/features.yml, so a LEXI flag there would
# take the place of the next flag upstream adds.
#
# internal_chat — fazer.ai's internal chat, off until a super admin switches it on.
module Lexi::Account
  FEATURES = { 'internal_chat' => 'Internal Chat' }.freeze

  FEATURES.each_key do |name|
    define_method(:"feature_#{name}?") do
      ActiveModel::Type::Boolean.new.cast((settings || {})["lexi_#{name}"]) || false
    end

    define_method(:"feature_#{name}=") do |value|
      self.settings = (settings || {}).merge("lexi_#{name}" => ActiveModel::Type::Boolean.new.cast(value) || false)
    end
  end

  def all_features
    super.merge(FEATURES.keys.index_with { |name| feature_enabled?(name) })
  end

  # Like the core setter, the chosen list replaces every flag, LEXI's included.
  def selected_feature_flags=(chosen_flags)
    lexi_flags = FEATURES.keys.map { |name| :"feature_#{name}" }
    chosen = chosen_flags&.map { |flag| flag.to_s.to_sym }

    FEATURES.each_key { |name| public_send(:"feature_#{name}=", chosen&.include?(:"feature_#{name}")) }
    super(chosen && (chosen - lexi_flags))
  end
end
