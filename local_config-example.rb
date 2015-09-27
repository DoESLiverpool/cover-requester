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

MAIL_SERVER = 'smtp.googlemail.com'
MAIL_PORT = 587
MAIL_DOMAIN = 'example.gmail.com'
MAIL_USER = 'example@gmail.example.com'
MAIL_PASS = 'yourpassword'
MAIL_AUTHTYPE = :login
MAIL_FROM_ADDRESS = "example@example.com"
MAIL_LONG_FROM_ADDRESS = "Example Generator <example@example.com>"
MAIL_REQUEST_ADDRESS = ["example-general@example.com"]
MAIL_LONG_REQUEST_ADDRESS = "Example General List <example-general@example.com>"
MAIL_COVER_ADDRESS = ["example-emergency@example.com"]
MAIL_LONG_COVER_ADDRESS = "Example Emergency Cover List <example-emergency@example.com>"

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


