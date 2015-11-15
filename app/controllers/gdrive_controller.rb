require 'google/api_client'
 
class GdriveController < ApplicationController
  CLIENT_ID = '174352150038-1qslp0m8eu8bts57bnfhhvcgl1sc77gv.apps.googleusercontent.com'
  CLIENT_SECRET = 'wZcda8U_fKx9aOVKidG7H8hU'
  REDIRECT_URI = 'http://localhost:3000'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
 
  def index
    session[:token] = params[:token]
 
    client = Google::APIClient.new
    drive = client.discovered_api('drive', 'v2')
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.scope = OAUTH_SCOPE
    client.authorization.redirect_uri = REDIRECT_URI
 
    uri = client.authorization.authorization_uri
    redirect_to uri.to_s
  end

  def callback
      client = Google::APIClient.new
      client.authorization.client_id = CLIENT_ID
      client.authorization.client_secret = CLIENT_SECRET
      client.authorization.redirect_uri = REDIRECT_URI
      client.authorization.code = params[:code]
      token_info = client.authorization.fetch_access_token!
      token_info['issue_timestamp'] = Time.now
      Session.set_gdrive_session(session[:token], token_info)
  end

end
