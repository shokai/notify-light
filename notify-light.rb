#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'json'
require 'ArgsParser'

parser = ArgsParser.parser
parser.comment(:skype, 'URL of Skype Chat Gateway')
parser.comment(:light, 'URL of Serial HTTP Gateway')
parser.comment(:interval, 'loop interval (sec)', 10)
parser.comment(:threshold, 'threshold of light', 0.03)

first, params = parser.parse ARGV

if parser.has_option(:help) or !parser.has_params([:skype, :light])
  puts parser.help
  puts "e.g.  ruby #{$0} -light http://localhost:8783/ -skype http://localhost:8787/"
  exit 1
end

lighting = false
@skype = params[:skype]

def notify(msg)
  uri = URI.parse @skype
  Net::HTTP.start(uri.host, uri.port) do |http|
    res = http.post(uri.path, msg)
    return true if res.code == '200'
  end
  false
end

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
  if avg >= params[:threshold].to_f and !lighting
    lighting = true if notify '明る〜い'
  elsif avg < params[:threshold].to_f and lighting
    lighting = false  if notify '暗い・・'
  end
  sleep params[:interval].to_i
end
