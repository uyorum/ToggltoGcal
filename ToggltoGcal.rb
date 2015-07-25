# -*- coding: utf-8 -*-
require_relative 'TogglReportsClient'
require_relative 'GoogleCalendarClient'
require 'yaml'

@config = YAML.load_file("config.yml")

@togglClient = TogglReportsClient.new(@config['Toggl'])

def push(entries)
  googleCalendarClient = GoogleCalendarClient.new(@config['GoogleCalendar'])
  
  @historyFilename = "history"
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
      # If there is no event in log, the event is newly added one.
      entry['eventid'] = googleCalendarClient.insert(entry['start'], entry['end'], "#{entry['project']}: #{entry['description']}")
    elsif DateTime.strptime(item['updated']) < DateTime.strptime(entry['updated'])
      # If there is newer updated datetime, the event was updated recently.
      entry['eventid'] = googleCalendarClient.update(item['eventid'], entry['start'], entry['end'], "#{entry['project']}: #{entry['description']}")
      log.delete(item)
    else
      entry['eventid'] = item['eventid']
      log.delete(item)
    end
  end

  # The item that is in log but not in entries are maybe deleted from Toggl.
  # If it isn't in Toggl, also delete it from Google Calendar.
  log.each do |item|
    unless @togglClient.have?(item['id'])
      googleCalendarClient.delete(item['eventid'])
    end
  end
  
  Pathname.new(@historyFilename).open('wb') do |f|
    Marshal.dump(entries, f)
  end
end

push(@togglClient.get)
