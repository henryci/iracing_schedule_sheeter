#!/usr/bin/ruby

require "iguvium"
require "json"

require "./iracing_format"
require "./output_handlers"

TRACKFILE = "tracks.json" # The json file representings all the known tracks + configurations

# Debugging flags
STOP_EARLY = false   # Set to true to to trigger an early stop (used for testing / debugging)
STOP_ON_PAGE = 6     # what page to stop on (if STOP_EARLY) is set
DUMP_TRACKS = false  # If set to true, dumps the list of known tracks

if !ARGV[0]
  puts "Usage: ./this_script.rb <PDF_from_iRacing>"
end

# An array of strings representing the output
output = []
all_tables = []

# Read the entire pdf, putting every table in memory
puts "Reading PDF: #{ARGV[0]}"
pages = Iguvium.read(ARGV[0])
current_page = 0
while pages.length > current_page
  if STOP_EARLY && current_page > STOP_ON_PAGE
    puts "Stopping early because STOP_EARLY is true"
    break
  end
  tables = pages[current_page].extract_tables!

  # if there are no tables skip the page
  if tables.length < 1
    puts "Skipping page: #{current_page} pdf: #{current_page + 1} because it has no tables"
    current_page += 1
    next
  end

  # otherwise add all tables to the list
  tables.each do |table|
    all_tables << table
  end

  current_page += 1
end

puts "Last page: #{current_page} tables read: #{all_tables.length}"

# Go through all the tables and generate the rows that will become the output
current_table = 0
while all_tables.length > current_table
  # read in the current table
  values = all_tables[current_table].to_a
  current_table += 1

  # keep reading in tables until we find the start of the next series
  # this is to deal with series that span multiple pages
  while !is_table_start_of_series(all_tables[current_table])
    all_tables[current_table].to_a.each do |next_row|
      values << next_row
    end
    current_table += 1
  end

  # Proces this set of values
  rows = get_rows_for_series(values)
  rows.each do |row|
    output << row
  end
end

if DUMP_TRACKS
  dump_tracks(output)
  exit
end

# read in the existing tracks
tracksFile = File.read(TRACKFILE)
tracks = JSON.parse(tracksFile)

# Generates the final output
generate_file(output, "output.tsv", tracks)
