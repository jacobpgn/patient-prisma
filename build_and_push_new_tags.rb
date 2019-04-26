#!/usr/bin/env ruby

require "date"
require "json"
require "net/http"
require "open3"

OLDEST_TAG_DATE = Date.today - 90

def repo_tags(repo:)
  first_page_uri = URI("https://registry.hub.docker.com/v2/repositories/#{repo}/tags/?page_size=100")
  all_tags(page_uri: first_page_uri)
end

def all_tags(page_uri:, last_updated_after_date: OLDEST_TAG_DATE)
  print "." if ENV["VERBOSE"]
  tags = []

  res = Net::HTTP.get_response(page_uri)
  page = JSON.parse(res.body)

  filtered_results = page["results"].select do |tag|
    Date.parse(tag["last_updated"]) >= OLDEST_TAG_DATE
  end.map do |tag|
    tag.slice("name", "last_updated")
  end

  tags += filtered_results

  reached_date_cutoff = filtered_results.size < page["results"].size

  if page["next"] && !reached_date_cutoff
    tags += all_tags(page_uri: URI(page["next"]))
  end

  tags
end

puts "Fetching existing tags"
prisma_tags  = repo_tags(repo: "prismagraphql/prisma")
patient_tags = repo_tags(repo: "jacobpgn/patient-prisma")
puts

# We'll build and push every prisma tag updated since OLDEST_TAG_DATE that
# doesn't have a corresponding patient-prisma tag yet
patient_tags_to_push = prisma_tags.select do |prisma_tag|
  patient_tags.none? { |patient_tag| patient_tag["name"] == prisma_tag["name"] }
end

# Oldest tags first, so our "recent tags" roughly match those of prisma
patient_tags_to_push.sort_by! { |tag| tag["last_updated"] }

pushed = []

puts "Building and pushing #{patient_tags_to_push.size} images"

patient_tags_to_push.each do |tag|
  puts "\e[1m#{pushed.size + 1}/#{patient_tags_to_push.size}\e[22m"
  puts "\e[33mRunning ./build_and_push_tag.sh #{tag["name"]}\e[0m"
  stdout, stderr, status = Open3.capture3("./build_and_push_tag.sh", tag["name"])

  if status.success?
    puts stdout if ENV["VERBOSE"]
    puts "\e[32mFinished for tag #{tag["name"]}\e[0m"
    pushed << tag
  else
    puts "\e[31mError for tag #{tag["name"]}\e[0m"
    raise "Error! #{stderr}" if stderr
  end
end
