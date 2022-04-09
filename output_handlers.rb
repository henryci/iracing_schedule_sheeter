CRASH_ON_NO_TRACK = false  # If set to true, causes an exit if an invalid track is found

# Goes through the output and collects all the track data and dumps it
def dump_tracks(output)
  tracks = {}
  output.each do |row|
    track_details = row[2].split(" - ") # TODO: Just use the index rather than split and rejoin
    name = track_details[0]
    config = name
    if track_details.length > 1
      config = track_details.slice(1, track_details.length).join(" - ")
    end
    tracks[row[2]] = { "name" => name, "config" => config }
  end
  puts "DUMPING TRACKS: #{tracks.keys.length}"
  puts JSON.dump(tracks)
end

# Generates the final TSV from the output rows
def generate_file(output, filename, tracks)
  unknown_tracks = {}
  open(filename, "w") do |f|
    f.puts "Series\tWeek\tTrack\tConfig"
    output.each do |line|
      series = line[0]
      week = line[1]

      track = tracks[line[2]]
      if !track
        unknown_tracks[line[2]] = { name: "", config: ""}
        exit if CRASH_ON_NO_TRACK
      else
        track_name = track["name"]
        track_config = track["config"]
        f.puts "#{series}\t#{week}\t#{track_name}\t#{track_config}"
      end
    end
  end

  if unknown_tracks.keys.length > 0
    puts "There are unknown tracks:"
    puts JSON.dump(unknown_tracks)
  else
    puts "There were no unknown tracks"
  end
end
