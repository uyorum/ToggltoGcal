# coding: utf-8
require 'google/api_client'
require 'pathname'
require 'json'

class GoogleCalendarClient

  def initialize(hash)
    # hash
    #  :issuer
    #  :calendarId
    #  :password
    @client = Google::APIClient.new(:application_name => 'ToggltoGcal')
     
    # authentication
    key = Google::APIClient::KeyUtils.load_from_pkcs12('ToggltoGcal.p12', hash['password'])
    @client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope => 'https://www.googleapis.com/auth/calendar',
      :issuer => hash['issuer'],
      :signing_key => key)
    @client.authorization.fetch_access_token!
    @cal = @client.discovered_api('calendar', 'v3')
    @params = {
      'calendarId' => hash['calendarId']
    }
  end

  def insert(startDateTime, endDateTime, summary)
    body = {
      'end' => {
        'dateTime' => endDateTime
      },
      'start' => {
        'dateTime' => startDateTime
      },
      'summary' => summary
    }
    response = @client.execute(:api_method => @cal.events.insert,
                               :parameters => @params,
                               :body_object => body)
    JSON.parse(response.body)['id']
  end

  def update(eventid, startDateTime, endDateTime, summary)
    body = {
      'end' => {
        'dateTime' => endDateTime
      },
      'start' => {
        'dateTime' => startDateTime
      },
      'summary' => summary,
      'eventId' => eventid
    }
    response = @client.execute(:api_method => @cal.events.update,
                               :parameters => @params.merge({'eventId' => eventid}),
                               :body_object => body)
    JSON.parse(response.body)['id']
  end

  def delete(eventid)
    response = @client.execute(:api_method => @cal.events.delete,
                               :parameters => @params.merge({'eventId' => eventid})
                              )
    nil
  end
end
