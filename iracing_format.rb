# Assume any table with values in in the second column of the first row
# is just a continuation of the previous table
def is_table_start_of_series(table)
  table_as_array = table.to_a
  return false if table_as_array[0] && table_as_array[1] && table_as_array[0][1].length > 1
  return true
end

# works through the rows of the series and returns all the values
def get_rows_for_series(values)
  output = []
  title = get_series_title(values[0][0])

  values.each_with_index do |row, index|
    next if index == 0
    week = row[0].split(" (")[0]
    track = row[1].split(" (")[0]

    output << [title, week, track]
  end

  return output
end

# The format for one of these guys is flaky
# We usually split on " - " but occassionally there are hiccups
def get_series_title(title_string)
  result = title_string.split(" -")[0]
  return result + " - Fixed" if title_string.include? "Fixed"
  return result
end
