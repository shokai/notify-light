#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'json'
require 'ArgsParser'

parser = ArgsParser.parser
parser.comment(:skype, 'URL of Skype Chat Gateway', 'http://localhost:8787/')
parser.comment(:light, 'URL of Serial HTTP Gateway', 'http://localhost:8783/')
parser.comment(:interval, 'loop interval (sec)', 10)
parser.comment(:threshold_light, 'threshold of light', 0.02)
parser.comment(:threshold_sun, 'threshold of sun', 0.3)
parser.bind(:help, :h, 'show help')

first, params = parser.parse ARGV

if parser.has_option(:help) or !parser.has_params([:skype, :light])
  puts parser.help
  puts "e.g.  ruby #{$0} -light http://localhost:8783/ -skype http://localhost:8787/"
  exit 1
end

@skype = params[:skype]
def notify(msg)
  puts msg
  uri = URI.parse @skype
  Net::HTTP.start(uri.host, uri.port) do |http|
    res = http.post(uri.path, msg)
    return true if res.code == '200'
  end
  false
end

# STATS = [:sun, :light, :dark]
stat = nil

loop do
  begin
    data = JSON.parse open(params[:light]).read
    avg = data.map{|i| i['data'].scan(/([\d\.]+)$/).first.first.to_f }.inject{|a,b|a+b}/data.size
  rescue StandardError, Timeout::Error=> e
    STDERR.puts e
    sleep params[:interval].to_i
    next
  end
  puts "light : #{avg}"
  if avg > params[:threshold_sun].to_f
    if stat != :sun
      stat = :sun if notify "太陽がでてる (#{avg})"
    end
  elsif avg > params[:threshold_light].to_f
    if stat != :light
      stat = :light if notify "電気ついてる (#{avg})"
    end
  else
    if stat != :dark
      stat = :dark if notify "暗い・・ (#{avg})"
    end
  end
  sleep params[:interval].to_i
end
