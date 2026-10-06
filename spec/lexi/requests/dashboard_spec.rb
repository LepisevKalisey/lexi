require 'rails_helper'

describe 'LEXI dashboard config', type: :request do
  it 'opens the premium screens to the dashboard while the stored plan stays community' do
    get '/app/login'

    expect(response).to have_http_status(:success)
    expect(response.body).to include("isEnterprise: 'true'")
    expect(response.body).to include("enterprisePlanName: 'lexi'")
    expect(ChatwootHub.pricing_plan).to eq('community')
  end
end
