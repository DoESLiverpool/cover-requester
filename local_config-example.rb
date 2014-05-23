# URL for the events calendar iCal feed
CAL_URL = ""

# If your calendar uses HTTPS rather than HTTP, set this to true
CAL_URL_IS_HTTPS = true

# Some properties for the resultant Doodle
TITLE_PREFIX = "Title" # will have W/C YYYY-MM-DD appended
DOODLE_ADMIN_NAME = "Admin Name"
DOODLE_ADMIN_EMAIL = "youremail@example.com"
DOODLE_LEVELS = 3 # 2 for Yes/No, 3 for Yes/No/If-need-be

# Oauth credentials from https://doodle.com/mydoodle/consumer/credentials.html
DOODLE_OAUTH_KEY = ""
DOODLE_OAUTH_SECRET = ""

# Filename to place the URL to the latest poll in
LATEST_POLL_FILENAME = "latest-poll.dat"

# The times of day that you need cover, default is AM/PM/Eve
TIME_SPANS = [
  {
    :start => 5*60*60,
    :end => 13*60*60,
    :label => "AM"
  },
  {
    :start => 13*60*60,
    :end => 18*60*60,
    :label => "PM"
  },
  {
    :start => 18*60*60,
    :end => 22*60*60,
    :label => "Eve"
  }
]

# If you know that you will always need cover at certain times of the week
# enter those here, default is Monday - Friday, AM & PM
DEFAULT_COVER_REQUESTED = [
  {
    :day => 0,
    :times => [ "AM", "PM" ]
  },
  {
    :day => 1,
    :times => [ "AM", "PM" ]
  },
  {
    :day => 2,
    :times => [ "AM", "PM" ]
  },
  {
    :day => 3,
    :times => [ "AM", "PM" ]
  },
  {
    :day => 4,
    :times => [ "AM", "PM" ]
  }
]


