# Creating and changing an inbox. Its deletion runs in DeleteObjectJob, which records it with the
# user who asked for it (Lexi::DeleteObjectJob); channel settings changes are recorded by
# Lexi::Channelable.
module Lexi::Audit::Inbox
  extend ActiveSupport::Concern

  included do
    audited associated_with: :account, on: %i[create update]
  end
end
