require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

class StaticPagesController < ApplicationController

  APPLICATION_NAME = 'Drive API Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "drive-quickstart.json")
  SCOPE = 'https://www.googleapis.com/auth/drive.metadata.readonly'

  def home
    if signed_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
    # Initialize the API
    client = Google::APIClient.new(:application_name => APPLICATION_NAME)
    client.authorization = authorize
    drive_api = client.discovered_api('drive', 'v2')

    # List the 10 most recently modified files.
    results = client.execute!(
      :api_method => drive_api.files.list,
      :parameters => { :maxResults => 10 })
    puts "Files:"
    puts "No files found" if results.data.items.empty?
    @picture_title = Array.new
    results.data.items.each do |file|
      # @picture_title.push(file.title)
      print_file(client, file.id)
    end
  end

  def about
  end

  def contact
  end

  private

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization request via InstalledAppFlow.
# If authorization is required, the user's default browser will be launched
# to approve the request.
#
# @return [Signet::OAuth2::Client] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
  storage = Google::APIClient::Storage.new(file_store)
  auth = storage.authorize

  if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
    app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    flow = Google::APIClient::InstalledAppFlow.new({
      :client_id => app_info.client_id,
      :client_secret => app_info.client_secret,
      :scope => SCOPE})
    auth = flow.authorize(storage)
    puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
  end
  auth
end

##
# Print a file's metadata.
#
# @param [Google::APIClient] client
#   Authorized client instance
# @param [String] file_id
#   ID of file to print
# @return nil
def print_file(client, file_id)
  drive = client.discovered_api('drive', 'v2')
  result = client.execute(
    :api_method => drive.files.get,
    :parameters => { 'fileId' => file_id })
  if result.status == 200
    file = result.data
    # binding.pry
    if file.title.include?("jpg")
      # original = Magick::Image.read(file.title).first
      # image = original.thumbnail(0.3)
      # file = image.write('resize1.png')
      @picture_title.push(file.webContentLink)
    end
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end

end
