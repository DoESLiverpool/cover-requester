#!/usr/bin/ruby
# check-cover.rb
# Script to check that the doodle poll to
# see if we have cover for tomorrow (/ any date).

require 'rubygems'
require 'pp'
require 'uri'
require 'net/http'
require 'net/smtp'
require 'time'
require 'json'
require_relative 'time_start_and_end_extensions'
require_relative 'local_config'

def usage
  puts "usage: check-cover.rb [-h] [email] [<YYYY-MM-DD>|nextweek] [<doodle-url>]"
end

if ! ARGV.index("-h").nil?
  usage
  exit
end

send_email = false

if ARGV[0] == "email"
  send_email = true
  ARGV.shift
end

check_date = ARGV.shift
poll_url = ARGV.shift
next_week = false

if check_date.nil?
  check_date = (Time.now + 1.day).strftime("%Y-%m-%d")
elsif check_date == "nextweek"
  next_week = true
  check_date = (Time.now.start_of_work_week + 7.days).strftime("%Y-%m-%d")
end

if poll_url.nil?
  week_start = Time.parse(check_date).start_of_work_week
  filename = File.dirname(__FILE__) + ("/doodle-%d-%02d-%02d.dat" % [ week_start.year, week_start.month, week_start.day ] )
  begin
    f = File.open(filename, "r")
    poll_url = f.read
    f.close
  rescue
    puts "Problem reading URL file for #{week_start.strftime("%Y-%m-%d")}.\n\n"
  end
end

if poll_url.nil? or ! check_date.match(/^\d{4}-\d{2}-\d{2}$/) or ! poll_url.match(/^http/)
  usage
  exit
end

for i in 0..5
  begin
    response = Net::HTTP.get_response(URI.parse(poll_url))
  rescue SocketError
    sleep 10
  end
  break if response
end

if response.nil?
  puts "Failed to load even with retries, giving up."
  exit 1
end

json = response.body
json = json.gsub(/.*\$\.extend\(true, doodleJS\.data, \{"poll":/m, '')
json = json.gsub(/\}\);\n.*/m, '')

poll = JSON.parse(json)

raise "Couldn't parse json" if json.nil?

options = poll["fcOptions"]
people = poll["participants"]

raise "Couldn't find options" if options.nil?
raise "Couldn't find people" if people.nil?


options.each do |option|
  option[:definites] = []
  option[:maybes] = []
end

people.each do |person|
  person["preferences"].split("").each_index do |i|
    pref = person["preferences"][i]
    if pref == 'y'
      options[i][:definites] << person["name"]
    elsif pref == 'i'
      options[i][:maybes] << person["name"]
    end
  end
end

lacking = []
options.each do |option|
  date = Time.at(option["start"]).strftime("%Y-%m-%d")
  day = Time.at(option["start"]).strftime("%A")
  if date == check_date and option[:definites].length == 0
    option["formatted_date"] = "#{day} #{date}"
    lacking << option
  end
end

if lacking.length > 0

  message_text = "We are missing cover for the following time periods:\n"
  lacking.each do |option|
    message_text += "    #{option["formatted_date"]} #{option["text"]} #{option[:maybes].length == 0 ? "(With no maybes)" : "(With these maybes: #{option[:maybes].join(", ")})" }\n"
  end
  message_text += "\nGo here to remedy: #{poll_url}\n"

  if send_email
  message = <<MESSAGE_END
From: #{MAIL_LONG_FROM_ADDRESS}
To: #{MAIL_LONG_NOTIFY_ADDRESS}
MIME-Version: 1.0
Content-Type: text/plain
Subject: #{ next_week ? "NEXT WEEK " : "" }Cover Required
#{message_text}
MESSAGE_END

    smtp = Net::SMTP.new MAIL_SERVER, MAIL_PORT
    smtp.enable_starttls
    smtp.start(MAIL_DOMAIN, MAIL_USER, MAIL_PASS, MAIL_AUTHTYPE) do
      smtp.send_message message, MAIL_FROM_ADDRESS, MAIL_NOTIFY_ADDRESS
    end
  else
    print message_text
  end
end
