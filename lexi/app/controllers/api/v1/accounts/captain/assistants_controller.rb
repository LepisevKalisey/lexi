# Compatibility stub. On an enterprise installation the dashboard loads Captain assistants on
# every page (CopilotContainer). LEXI does not implement Captain, so the list stays empty
# instead of a 404 on each page load. Other assistant actions keep answering 404.
class Api::V1::Accounts::Captain::AssistantsController < Api::V1::Accounts::BaseController
  def index
    render json: { payload: [], meta: { total_count: 0, page: 1 } }
  end
end
