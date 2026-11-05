module Lexi::Audit::Webhook
  extend ActiveSupport::Concern

  included do
    audited associated_with: :account, except: %i[secret]
  end
end
