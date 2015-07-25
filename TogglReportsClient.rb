# -*- coding: utf-8 -*-
require_relative 'toggl_reports_v2/TogglReportsV2'

class TogglReportsClient
  USED_KEYS = ["id", "start", "end", "updated", "description", "client", "project"]

  TogglReportsClient < TogglReports
  attr_reader :entry
  
  def initialize(hash)
    # @conf(hash)
    #  :api_key
    #  :user_agent
    #  :workspace_id
    #  :length(day)
    @conf = hash
    @client = TogglReports.new(@conf['api_key'])
  end

  def get
    now = DateTime.now

    params = {
      :user_agent => @conf['user_agent'],
      :workspace_id => @conf['workspace_id'],
      :until => now.to_s,
      :since => (now - @conf['length'].to_i).to_s
    }
    # delete keys which are not needed
    entries = @client.get("details", params)['data'].each do |entry|
      entry.each_key do |key|
        entry.delete(key) unless USED_KEYS.include?(key)
      end
    end
    entries
  end

  def have?(id)
    now = DateTime.now

    params = {
      :user_agent => @conf['user_agent'],
      :workspace_id => @conf['workspace_id'],
      :until => now.to_s,
      :since => (now - @conf['length'].to_i * 2).to_s,
      :time_entry_ids => id.to_s
    }

    if @client.get("details", params)['total_count'] == 0
      return false
    else
      return true
    end
  end
end
