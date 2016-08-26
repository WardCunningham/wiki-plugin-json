# check sanity of json metadata
# usage: while sleep 1; do ruby check-metadata.rb; done

require 'json'
page = JSON.parse `curl -s http://ward.asia.wiki.org/json-plugin.json`
item = page['story'][4]
now = Time.now.to_i
puts "write: #{item['writes']} written: #{now - item['written'].to_i/1000} interval: #{item['interval']}"