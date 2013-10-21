#!/usr/bin/ruby
# request-cover
# Script to generate a doodle poll to find out who can cover opening and
# closing of an events space.

require 'rubygems'
require 'pp'
require 'uri'
require 'net/http'
require 'time'
# Note that default ri_cal sets finish of all day events incorrectly to the end of the
# following day rather than the start, johnmckerrell's fork has "fixed" this.
require 'ri_cal'
require 'builder'
gem 'oauth'
require 'oauth'
require_relative 'time_start_and_end_extensions'
require_relative 'local_config'

def doodle_xml(args)
# Example Doodle XML
#<poll xmlns="http://doodle.com/xsd1"> <latestChange>2008-07-23T16:40:50+02:00</latestChange> <id>rgnrsqvsirr5s22s</id>
#<type>DATE</type>
#<extensions rowConstraint="1" columnConstraint="5"/>
#<hidden>false</hidden>
#<writeOnce>false</writeOnce>
#<requireAddress>false</requireAddress>
#<requireEMail>false</requireEMail>
#<requirePhone>false</requirePhone>
#<byInvitationOnly>false</byInvitationOnly>
#<levels>2</levels>
#<state>OPEN</state>
#<title>Date Options and Extensions</title>
#<description></description>
#<initiator>
#<name>Paul</name>
#<userId></userId>
#</initiator>
#<options>
#<option date="2008-08-26"/>
#<option date="2008-08-27">noon</option>
#<option startDateTime="2008-08-27T15:00:00" endDateTime="2008-08-27T17:00:00"/> <option date="2008-08-28">Austin</option>
#<option date="2008-08-28">Zurich</option>
#</options>

  xml = Builder::XmlMarkup.new( :indent => 2 )
  xml.instruct! :xml, :encoding => "utf8"
  xml.poll("xmlns" => "http://doodle.com/xsd1") {
    xml.type(args["type"])
    xml.levels(args["levels"])
    xml.state("OPEN")
    xml.title(args["title"])
    xml.description
    xml.initiator() {
      xml.name(args["name"])
      xml.eMailAddress(args["eMailAddress"])
    }
    xml.options() {
      args["options"].each do |o|
        o["cover"].each do |span|
          xml.option(span, "date" => o["date"])
        end
      end
    }
  }
end

dry_run = !! ARGV.index('-n')

week_start = (Time.now + 7.days).start_of_work_week
week_end = week_start + 7.days

# Get upcoming calendar events
events = []
# Download and parse the calendar
if CAL_URL.length > 0
  if (CAL_URL_IS_HTTPS)
    cal_uri = URI.parse(CAL_URL)
    cal_http = Net::HTTP.new(cal_uri.host, 443)
    cal_http.use_ssl = true
    cal_req = Net::HTTP::Get.new(cal_uri.request_uri)
    cal_data = cal_http.request(cal_req)
  else
    cal_data = Net::HTTP.get_response(URI.parse(CAL_URL))
  end
  all_events = RiCal.parse_string(cal_data.body)
else
  all_events = []
end
# Find any relevant events
all_events.each do |cal|
  cal.events.each do |ev|
    event_start = ev.start_time
    event_end = ev.finish_time
    recurring_occurrence = nil
    if ev.recurs?
      # This is a recurring event, so work out the start of the next occurrence
      next_occurrence = ev.occurrences(:count => 1, :starting => week_start)
      unless next_occurrence.empty?
        event_start = next_occurrence[0].start_time
        event_end = next_occurrence[0].finish_time
        recurring_occurrence = next_occurrence[0]
      end
    end
    # Crude type conversion because event times are DateTime objects
    # and the [start|end]_of_this_week variables are Time objects
    event_start = Time.parse(event_start.to_s)
    event_end = Time.parse(event_end.to_s)
    if event_start >= week_start && event_start <= week_end
      events.push({:start=>event_start,:end=>event_end,:summary=>ev.summary,:event=>ev,:recur=>recurring_occurrence})
    end
  end
end



args = {
  "type" => "DATE",
  "title" => "#{TITLE_PREFIX} W/C #{week_start.strftime("%Y-%m-%d")}",
  "levels" => DOODLE_LEVELS,
  "name" => DOODLE_ADMIN_NAME,
  "eMailAddress" => DOODLE_ADMIN_EMAIL,
  "options" => []
}

# Go through the 7 days of the week, get the default cover and supplement it
# with any additional cover required for events.
for day in 0..6
  cover = DEFAULT_COVER_REQUESTED.find { |d| d[:day] == day }
  if cover
    cover = cover[:times]
  else
    cover = []
  end
  day_start = (week_start+(day*1.day))
  daystr = day_start.strftime("%Y-%m-%d")

  # Go through each of the configured time spans and if there's an event during
  # one, add it to the list of times we need to cover.
  TIME_SPANS.each do |span|
    span_start = day_start + span[:start]
    span_end = day_start + span[:end]
    events.each do |ev|
      if ev[:start] >= span_start and ev[:start] < span_end
        # event starts during this span
      elsif ev[:end] >= span_start and ev[:end] < span_end
        # event ends during this span
      elsif ev[:start] < span_start and ev[:end] > span_end
        # event envelops this span
      else
        next
      end
      if dry_run
        puts "#{daystr} #{span[:label]}: #{ev[:summary]}"
      end
      cover << span[:label] unless cover.index(span[:label])
    end
  end


  # If we don't need cover, we don't need to add the day at all
  if cover.length > 0
    args["options"] << { "date" => daystr, "cover" => cover }
  end
end

# Generate the XML
xml = doodle_xml(args)

if dry_run
  puts xml
  exit
end

# Submit the XML using Doodle's OAuth API
consumer = OAuth::Consumer.new DOODLE_OAUTH_KEY, DOODLE_OAUTH_SECRET, {:site=>"https://doodle.com", :http_method => :get, :request_token_path => '/api1/oauth/requesttoken', :access_token_path => '/api1/oauth/accesstoken' }

request_token = consumer.get_request_token
access_token = request_token.get_access_token
response = access_token.post( '/api1/polls', xml, { 'Content-Type' => 'application/xml' })
puts response.body
puts response.inspect
