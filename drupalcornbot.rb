# Requires daemon
#require 'daemons'
#Daemons.daemonize

require "cinch"
require "forecast_io"
require "indefinite_article"
require_relative "../Quintus_cinch-plugins/plugins/history"
require_relative "../Quintus_cinch-plugins/plugins/link_info"
require_relative "../cinch-identify/lib/cinch/plugins/identify"
require_relative "../cornbot-identity"

# class Daytime
#   include Cinch::Plugin
#
#   t = Time.now
#
#   morningtime.new(
#     Time.local(t.year, t.month, t.day, 5),
#     Time.local(t.year, t.month, t.day, 12)
#   ) === t
#
#   afternoontime.new(
#     Time.local(t.year, t.month, t.day, 12, 01),
#     Time.local(t.year, t.month, t.day, 17)
#   ) === t
#
#   eveningtime.new(
#     Time.local(t.year, t.month, t.day, 17),
#     Time.local(t.year, t.month, t.day, 20)
#   ) === t
#
#   nighttime.new(
#     Time.local(t.year, t.month, t.day, 20),
#     Time.local(t.year, t.month, t.day, 5)
#   ) === t
#
# end

class PHPfilter
  include Cinch::Plugin

  match /hate php filter/i, use_prefix: false
  def execute(m)
    m.reply "Use this to kill the PHP Filter module without hacking core.  https://github.com/hofmockel/php/blob/master/README.md"
  end
end

class Morning
  include Cinch::Plugin

  match /morning/i, use_prefix: false
  def execute(m)
    ForecastIO.api_key = FORECASTIOAPIKEY
    forecast = ForecastIO.forecast(42, 93, params: { exclude: 'minutely,hourly,daily,alerts,flags'})
    when 'clear-day'
      adjective = ["clear", "sunny", "crisp", "bright", "sparkly", "beautiful", "sunny sunny"].sample
    when 'rain'
      adjective = ["rainy", "wet", "damp", "aqueous", "drizzly", "grey"].sample
    when 'snow'
      adjective = ["snowy", "wintery", "flaky"].sample
    when 'sleet'
      adjective = ["sleety", "great day to be alive this", "fresh", "slippery"].sample
    when 'wind'
      adjective = ["windy", "blustery"].sample
    when 'fog'
      adjective = ["foggy", "foggy foggy", "thick as pea soup out there this"].sample
    when 'cloudy'
      adjective = ["cloudy", "overcast", "cozy", "huddly"].sample
    when 'partly-cloudy-day'
      adjective = ["beautiful", "promising", "super"].sample
    else
      adjective = ["crisp", "blustery", "wintery", "snowy", "slushy", "slippery", "windy", "frozen", "beautiful", "sparkly"].sample
    end    
    species = ["polar bears", "penguins", "seals", "huskies", "arctic foxes", "snowy owls", "beluga whales", "Harp Seal", "squash"].sample
    verbing = ["cozy", "snug", "freezing", "shuffling", "gathering", "singing the blues", "sleeping", "playing", "waddling", "flapping"].sample
    if species == "squash"
       verbing = "being hunted"
    end
    a_or_an = adjective.indefinite_article
    m.reply "Morning, #{m.user.nick}. It's #{a_or_an} #{adjective} morning and the #{species} are #{verbing}!"
  end
end

class Afternoon
  include Cinch::Plugin

  match /afternoon/i, use_prefix: false
  def execute(m)
    preadverb = ["certainly", "sure", "absolutely", "unquestionably", ""].sample
    preadverb << ' ' if !preadverb.empty?
    verbed = ["worked hard", "innovated", "been creative", "set an example", "led the way", "created something new", "rocked the world"].sample
    adverb = ["awesomely", "in a grand fashion", "wonderfully", "superbly", "delightfully", "magnificently", ""].sample
    adverb << ' ' if !adverb.empty?
    whenitwas = ["today", "this morning", "these last few days", "these last couple days", "lately", "since DrupalCorn"].sample
    m.reply "Afternoon, #{m.user.nick}. You've #{preadverb}#{verbed} #{adverb}#{whenitwas}!"
    time = Time.new
    if ("13:30"..."13:44").include?(time.strftime("%H:%M")) and [true, false].sample
      m.reply "It's tea time!"
    end
  end
end

class WTF
  include Cinch::Plugin

  match /wtf/i, use_prefix: false
  def execute(m)
    m.reply "WTF?  http://youtu.be/N3YypTOaa08"
  end
end

class Help
  include Cinch::Plugin

  match /help(?: (\S+))?/
  def execute(m)
    m.reply "I respond to the following commands: hello, !help, !DrupalCorn, Central Iowa, DrupalHawks, /msg cornbot history"
    m.reply "For more information see - https://github.com/hofmockel/cornbot"
  end
end

class CentralIowa
  include Cinch::Plugin

  match /^(cidug|drupalcob|central iowa)$/i, use_prefix: false
  def execute(m)
    m.reply "We meet the 2nd Thursday of every month from 7pm - 9pm usually followed by beers at a local watering hole."
    m.reply "Meetings are in Room 8, Curtiss Hall on the ISU campus. It is easy to get to."
    m.reply "https://groups.drupal.org/iowa"
    m.reply "Google Map - http://goo.gl/maps/dIINj"
  end
end

class DrupalCorn
  include Cinch::Plugin

  match /drupalcorn/i
  def execute(m)
    m.reply "DrupalCorn Camp is a Drupal Camp, held each year somewhere in the state of Iowa."
    m.reply "Latest camp:"
    m.reply "http://2013.drupalcorn.org"
  end
end

class DrupalHawks
  include Cinch::Plugin

  match /drupalhawks/i, use_prefix: false
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
    c.nick = IDENTITY
    c.plugins.plugins = [PHPfilter, Morning, Afternoon, CentralIowa, DrupalCorn, DrupalHawks, Help, WTF, Cinch::History, Cinch::Plugins::Identify, Cinch::LinkInfo]
    c.plugins.options[Cinch::History] = {
     :mode => :max_messages,
     :max_messages => 20,
     # :max_age => 5,
     :time_format => "%H:%M"
    }
    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => IDENTITY,
      :password => PASSWORD,
      :type     => :nickserv,
    }
    c.plugins.options[Cinch::LinkInfo] = {
      :blacklist => [/\.xz$/]
    }
  end
end

bot.start
