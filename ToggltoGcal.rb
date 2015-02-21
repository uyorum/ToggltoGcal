# -*- coding: utf-8 -*-
require_relative 'TogglReportsClient'
require_relative 'GoogleCalendarCLient'
require 'yaml'

config = YAML.load_file("config.yml")

togglClient = TogglReportsClient.new(config['Toggl'])
googleCalendarClient = GoogleCalendarClient.new(config['GoogleCalendar'])

googleCalendarClient.push(togglClient.get)
