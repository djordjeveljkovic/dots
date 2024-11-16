# Define a hash table mapping each hour to its respective icon
$hourIcons = @{
    "00" = '\udb85\udc4a'  # Unicode equivalent for 1
    "01" = "\udb85\udc3f"  # Unicode equivalent for 1
    "02" = "\udb85\udc40"  # Unicode equivalent for 2
    "03" = "\udb85\udc41"  # Unicode equivalent for 3
    "04" = "\udb85\udc42"  # Unicode equivalent for 4
    "05" = "\udb85\udc43"  # Unicode equivalent for 5
    "06" = "\udb85\udc44"  # Unicode equivalent for 6
    "07" = "\udb85\udc45"  # Unicode equivalent for 7
    "08" = "\udb85\udc46"  # Unicode equivalent for 8
    "09" = "\udb85\udc47"  # Unicode equivalent for 9
    "10" = "\udb85\udc48"  # Unicode equivalent for 10
    "11" = "\udb85\udc49"  # Unicode equivalent for 11
    "12" = "\udb85\udc4a"  # Unicode equivalent for 12
    "13" = "\udb85\udc3f"  # Repeat for 1
    "14" = "\udb85\udc40"  # Repeat for 2
    "15" = "\udb85\udc41"  # Repeat for 3
    "16" = '\udb85\udc42'  # Repeat for 4
    "17" = "\udb85\udc43"  # Repeat for 5
    "18" = "\udb85\udc44"  # Repeat for 6
    "19" = "\udb85\udc45"  # Repeat for 7
    "20" = "\udb85\udc46"  # Repeat for 8
    "21" = "\udb85\udc47"  # Repeat for 9
    "22" = "\udb85\udc48"  # Repeat for 10
    "23" = "\udb85\udc49"  # Repeat for 11
}
# Get the current hour as a number (0 to 23)
$currentHour = [int](Get-Date -Format "HH")

# Calculate the corresponding 12-hour clock value
# This maps 0 -> 0 (12), 1 -> 1, ..., 11 -> 11, 12 -> 0 (12), 13 -> 1, ..., 23 -> 11
$mappedHour = $currentHour % 12

# Set the mapped value in the environment variable
$env:HOUR_AM_PM = $mappedHour

