# frozen_string_literal: true

require 'administrate/field/base'

# Account feature flags as checkboxes named enabled_features[feature_<name>], the parameter
# SuperAdmin::AccountsController#resource_params already turns into selected_feature_flags.
# That setter clears every flag first, so flags the form does not show (Chatwoot-internal and
# deprecated ones) are carried in hidden inputs while enabled, instead of being switched off.
class Lexi::AccountFeatureFlagsField < Administrate::Field::Base
  # [[name, display_name, enabled], ...], regular features first, then premium ones
  def features
    SuperAdmin::AccountFeaturesHelper.filtered_features(data).map do |(name, display_name), enabled|
      [name, display_name, enabled]
    end
  end

  def hidden_enabled_features
    shown = features.map(&:first)
    data.select { |name, enabled| enabled && shown.exclude?(name) }.keys
  end
end
