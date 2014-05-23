# A small script to request weekly cover for DoES Liverpool

Generates a doodle for the following work week, can look in a calendar
to check whether there are evening events on.

See `local_config-example.rb` for examples of configuration.

Currently uses a fork of `ri_cal` to handle a bug in how finish time
of all day events is calculated, find that here:
    https://github.com/johnmckerrell/ri_cal

## Checking Coverage

Now also includes a script: check-cover.rb which will check to see
what days have no cover and will generate output that can be piped
to an email.
