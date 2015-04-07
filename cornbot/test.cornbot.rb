# Requires daemon
#require 'daemons'
#Daemons.daemonize

require "cinch"
require "forecast_io"
require "indefinite_article"
require "date"
require_relative "./quintus_cinch-plugins/plugins/history"
require_relative "./quintus_cinch-plugins/plugins/link_info"
require_relative "./cinch_identify/lib/cinch/plugins/identify"
require_relative "../test.cornbot-identity"

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

class Date
  include Cinch::Plugin
  
  def season
    day_hash = month * 100 + mday
    case day_hash
      when 101..401 then :winter
      when 402..630 then :spring
      when 701..930 then :summer
      when 1001..1231 then :fall
    end
  end
end

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
    forecast = ForecastIO.forecast(42, -93, params: { exclude: 'minutely,hourly,daily,alerts,flags'})
    case forecast.currently.icon
    when 'clear-day'
      adjective = ["clear", "sunny", "crisp", "bright", "sparkly", "beautiful", "sunny sunny"].sample
    when 'rain'
      adjective = ["rainy", "wet", "damp", "aqueous", "drizzly", "grey"].sample
    when 'snow'
      adjective = ["snowy", "wintery", "flaky"].sample
    when 'sleet'
      adjective = ["sleety", "great day to be alive this", "fresh", "slippery"].sample
    when 'wind'
      adjective = ["windy", "blustery", "breezy", "gusty"].sample
    when 'fog'
      adjective = ["foggy", "foggy foggy", "thick as pea soup out there this"].sample
    when 'cloudy'
      adjective = ["cloudy", "overcast", "cozy", "huddly", "murky", "turbid"].sample
    when 'partly-cloudy-day'
      adjective = ["beautiful", "promising", "super"].sample
    else
      adjective = ["crisp", "cool", "refreshing", "warm", "beautiful", "delightful", "inviting", "new", "unpredictable"].sample
    end    
    species = ["leverets", "lambs", "fawns", "ground hogs", "robins", "larval", "kits", "swans", "owls", "frogs", "spiders", "squash"].sample
    verbing = ["wandering","wailing","flocking", "licking the dew", "making a leaf pile", "fattening for winter", "stalking", "spinning", "peeping", "looking for a cave", "considering the autumnal", "creeping"].sample
    if species == "squash"
       verbing = "being hunted"
    end
    a_or_an = adjective.indefinite_article
    d = Date.today
    m.reply "Morning, #{m.user.nick}. It's #{a_or_an} #{adjective} #{d.season} morning and the #{species} are #{verbing}!"
  end
end

class Afternoon
  include Cinch::Plugin

  match /afternoon/i, use_prefix: false
  def execute(m)
    preadverb = ["certainly", "sure", "absolutely", "unquestionably", ""].sample
    preadverb << ' ' if !preadverb.empty?
    verbed = ["worked hard", "innovated", "been creative", "set an example", "led the way", "created something new", "rocked the world"].sample
    adverb = ["awesomely", "in a grand fashion", "wonderfully", "superbly", "delightfully", "magnificently", "inventively", "ingeniously"].sample
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
    m.reply "WTF?  https://www.youtube.com/watch?v=LrF_SYzvO78"
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

  match /cidug/i, use_prefix: false
  match /drupalcob/i, use_prefix: false
  match /central iowa/i, use_prefix: false
  def execute(m)
    m.reply "We meet the 2nd Thursday of every month from 7pm - 9pm usually followed by beers at a local watering hole."
    m.reply "Meetings are in Ames"
    m.reply "https://groups.drupal.org/iowa"
  end
end

class DrupalCorn
  include Cinch::Plugin

  match /drupalcorn/i
  def execute(m)
    m.reply "DrupalCorn Camp is a Drupal Camp, held each year somewhere in the state of Iowa."
    m.reply "Latest camp:"
    m.reply "http://drupalcorn.org"
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
    c.channels = ["#testcornbot"]
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
