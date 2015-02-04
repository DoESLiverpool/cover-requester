#!/usr/bin/ruby
# check-cover.rb
# Script to check that the doodle poll to
# see if we have cover for tomorrow (/ any date).

require 'rubygems'
require 'pp'
require 'uri'
require 'net/http'
require 'time'
require 'json'
require_relative 'time_start_and_end_extensions'
require_relative 'local_config'

def usage
  puts "usage: check-cover.rb <doodle-url> [<YYYY-MM-DD>]"
end

if ARGV.length < 1
  usage
  exit
end

poll_url = ARGV.shift
check_date = ARGV.shift

if check_date.nil?
  check_date = (Time.now + 1.day).strftime("%Y-%m-%d")
end

response = Net::HTTP.get_response(URI.parse(poll_url))

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
  puts "We are missing cover for the following time periods:"
  lacking.each do |option|
    puts "    #{option["formatted_date"]} #{option["text"]} #{option[:maybes].length == 0 ? "(With no maybes)" : "(With these maybes: #{option[:maybes].join(", ")})" }"
  end
  puts
  puts "Go here to remedy: #{poll_url}"
end
