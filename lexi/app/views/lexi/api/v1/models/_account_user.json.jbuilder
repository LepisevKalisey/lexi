json.custom_role_id account_user.custom_role_id
if account_user.custom_role
  json.custom_role do
    json.partial! 'api/v1/models/custom_role', custom_role: account_user.custom_role
  end
else
  json.custom_role nil
end
