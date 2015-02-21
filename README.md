# What is this?
A Ruby script which creates events on Google Calendar based on time entries on Toggl, the service for time tracking.

# How to use?

1. Checkout source codes to your computer.
1. Checkout API client for Toggl from [here](https://github.com/uyorum/toggl_reports_v2) to created directory.
1. Create a project and service account for this script from [here](https://console.developers.google.com/).
1. Download the recret key for the account and save it in the same directory. The filename should be 'ToggltoGcal.p12'.
1. Add permission on the calendar you use to the account.
1. `$ cp config.yml.example config.yml`
1. Edit config.yml.
1. `$ bundle install`
1. `$ bundle exec ruby ToggltoGcal.rb`
