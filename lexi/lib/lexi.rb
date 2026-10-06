# frozen_string_literal: true

# LEXI: open implementations of Chatwoot premium features on top of the fazer.ai fork.
# Everything lives under lexi/; enterprise/ is never part of a LEXI build. See lexi/README.md.
module Lexi
  VERSION = '0.1.0'

  # Installation plan the dashboard sees. Any plan but "community" lifts the enterprise upsell
  # screens; the account feature flags then decide what each account gets.
  PLAN_NAME = 'lexi'
end
