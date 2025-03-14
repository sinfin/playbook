#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'fileutils'
require 'uri'
require 'optparse'

# Default configuration
BRANCH = "main"
GITHUB_API_BASE = "https://api.github.com"
RAW_CONTENT_BASE = "https://raw.githubusercontent.com"

# Paths
CURSOR_RULES_DIR = ".cursor/rules"
CURSOR_CONFIG = ".cursor/config.json"

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  
  opts.on("-u", "--url URL", "GitHub repository URL (e.g. @https://github.com/sinfin/playbook)") do |url|
    options[:url] = url
  end
  
  opts.on("-b", "--branch BRANCH", "Branch to pull from (default: main)") do |branch|
    options[:branch] = branch
  end
  
  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

# Parse repository from URL
def parse_repo_from_url(url)
  # Handle @https:// format
  url = url.sub(/^@/, '') if url.start_with?('@')
  
  # Parse the URL
  uri = URI.parse(url)
  
  if uri.host == "github.com" && !uri.path.empty?
    # Remove leading slash and split by slash
    path_parts = uri.path.sub(/^\//, '').split('/')
    
    if path_parts.length >= 2
      return "#{path_parts[0]}/#{path_parts[1]}"
    end
  end
  
  nil
end

# Get repository from URL or default
repo_url = options[:url] || "@https://github.com/sinfin/playbook"
branch = options[:branch] || BRANCH

repo = parse_repo_from_url(repo_url)
unless repo
  puts "Error: Invalid GitHub repository URL: #{repo_url}"
  puts "Expected format: @https://github.com/username/repository"
  exit 1
end

puts "Using repository: #{repo}, branch: #{branch}"

def get_github_directory_contents(repo, branch, path)
  uri = URI.parse("#{GITHUB_API_BASE}/repos/#{repo}/contents/#{path}?ref=#{branch}")
  response = Net::HTTP.get_response(uri)
  
  if response.code == "200"
    JSON.parse(response.body)
  else
    puts "Error fetching directory contents: #{response.body}"
    []
  end
end

def download_file(repo, branch, path)
  uri = URI.parse("#{RAW_CONTENT_BASE}/#{repo}/#{branch}/#{path}")
  response = Net::HTTP.get_response(uri)
  
  if response.code == "200"
    response.body
  else
    puts "Error downloading file #{path}: #{response.body}"
    nil
  end
end

def sync_file(repo, branch, remote_path, local_path)
  content = download_file(repo, branch, remote_path)
  return unless content
  
  if File.exist?(local_path)
    if File.read(local_path) == content
      puts "File #{local_path} is already up to date."
      return
    end
    
    print "File #{local_path} already exists. Overwrite? (y/n): "
    return unless STDIN.gets.chomp.downcase == 'y'
  end
  
  # Create directory if it doesn't exist
  FileUtils.mkdir_p(File.dirname(local_path))
  
  # Write the file
  File.write(local_path, content)
  puts "Synced #{local_path}"
end

# Main execution
puts "Syncing Cursor rules and config from #{repo}..."

# Sync rules directory
rules = get_github_directory_contents(repo, branch, CURSOR_RULES_DIR)
rules.each do |file|
  next if file["type"] != "file"
  sync_file(repo, branch, "#{CURSOR_RULES_DIR}/#{file['name']}", "#{CURSOR_RULES_DIR}/#{file['name']}")
end

# Sync config.json
sync_file(repo, branch, CURSOR_CONFIG, CURSOR_CONFIG)

puts "Sync completed!"
