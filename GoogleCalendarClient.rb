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
    @historyFilename = "history"
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

  def push(entries)
    log = []
    begin
      Pathname.new(@historyFilename).open('rb') do |f|
        log = Marshal.load(f)
      end
    rescue Errno::ENOENT
      Pathname.new(@historyFilename).open('wb') do |f|
        Marshal.dump([], f)
      end
    end
    
    entries.each do |entry|
      item = log.find {|item| item['id'] == entry['id']}
      if item == nil
        # if there is no event in log
        entry['eventid'] = insert(entry['start'], entry['end'], "#{entry['project']}: #{entry['description']}")
      elsif DateTime.strptime(item['updated']) < DateTime.strptime(entry['updated'])
        # if there is newer updated datetime
        entry['eventid'] = update(item['eventid'], entry['start'], entry['end'], "#{entry['project']}: #{entry['description']}")
      else
        entry['eventid'] = item['eventid']
      end
    end
    
    Pathname.new(@historyFilename).open('wb') do |f|
      Marshal.dump(entries, f)
    end
    
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
  
  private :insert, :update   
end
