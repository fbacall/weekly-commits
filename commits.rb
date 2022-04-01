#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'yaml'

config_path = File.join(__dir__, 'config.yml')

unless File.exist?(config_path)
  STDERR.puts "config.yml missing! Please copy config.yml.example"
  exit(1)
end
config = YAML.load(File.read(config_path))
USER = config['user']
TOKEN = config['token']
EMAILS = (config['emails'] || []).map(&:downcase)

def fetch_events(page)
  json = URI.open("https://api.github.com/users/#{USER}/events?page=#{page}", 'Authorization' => "token #{TOKEN}").read
  JSON.parse(json)  
end

weeks = (ARGV[0] || '1').to_i - 1
today = Date.today
monday = today - (((today.wday - 1) % 7) + (7 * weeks))
start_time = monday.to_time # Midnight on Monday

events = []
page = 1

# Get all events from this week
loop do 
  events += fetch_events(page)
  break if Time.parse(events.last['created_at']) < start_time
  page += 1
  sleep 1
end

# Parse time
events.each do |event|
  event['time'] = Time.parse(event['created_at'])
end

# Select this week's PushEvents by me
events.select! do |event|
  event['time'] = Time.parse(event['created_at'])
  event['type'] == 'PushEvent' &&
    event['time'] >= start_time && event['payload']['commits'].any? { |c| EMAILS.include?(c['author']['email'].downcase) }
end

# Group by day of week
grouped = events.group_by do |event|
  "#{event['time'].iso8601[0..9]} (#{event['time'].strftime('%A')})"
end

# Print
grouped.each do |day, events|
  puts day
  events.each do |event|
    repo = event['repo']['name']
    branch = event['payload']['ref'].split('/').last
    event['payload']['commits'].each do |commit|
      next unless EMAILS.include?(commit['author']['email'].downcase)
      puts "  * #{repo}@#{branch} - #{commit['message'].split("\n").join("\n      ")}"
    end
  end
  puts
end
