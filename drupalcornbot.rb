# Requires daemon
#require 'daemons'
#Daemons.daemonize

require "cinch"
require_relative "../Quintus_cinch-plugins/plugins/history"

class HelloWorld
  include Cinch::Plugin

  match /hello/i, use_prefix: false
  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end

class Help
  include Cinch::Plugin

  match /help(?: (\S+))?/
  def execute(m)
    m.reply "I respond to the following commands: hello, !help, !drupalcorn-group, !drupalcorn-camp, !drupalhawks-group, /msg cornbot history"
  end
end


class DrupalCorn
  include Cinch::Plugin

  match "drupalcorn-group"
  def execute(m)
    m.reply "We meet the last Thursday of every month from 7pm - 9pm usually followed by beers at a local watering hole."
    m.reply "Meetings are in Room 8, Curtiss Hall on the ISU campus. It is easy to get to."
    m.reply "https://groups.drupal.org/iowa"
    m.reply "Google Map - http://goo.gl/maps/dIINj"
  end

  match "drupalcorn-camp"
  def execute(m)
    m.reply "DrupalCorn Camp is a Drupal Camp, held each year somewhere in the state of Iowa."
    m.reply "Latest camp:"
    m.reply "http://2013.drupalcorn.org"
  end
end

class DrupalHawks
  include Cinch::Plugin

  match "drupalhawks-group"
  def execute(m)
    m.reply "We are a collection of Drupal enthusiasts from Eastern Iowa."
    m.reply "We don't have a regular meeting time currently, but would love for someone to organize this. :)"
    m.reply "https://groups.drupal.org/drupalhawks"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.channels = ["#drupalcorn"]
    c.nick = "cornbot"
    c.plugins.plugins = [HelloWorld, DrupalCorn, Help, Cinch::History]
    c.plugins.options[Cinch::History] = {
     :mode => :max_messages,
     :max_messages => 20,
     # :max_age => 5,
     :time_format => "%H:%M"
    }
  end
end

bot.start