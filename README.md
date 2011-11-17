Klout [![Build Status](https://secure.travis-ci.org/cdamian/klout-rb.png)](http://travis-ci.org/cdamian/klout-rb)
=====
Ruby wrapper for the Klout REST API

Installation
------------

Klout is available through [Rubygems](http://rubygems.org/gems/klout-rb) and can be installed via:

    gem install klout-rb

Usage
-----

#### Configure API key

    Klout::Client.configure do |config|
      config.api_key = "<YOUR_API_KEY>"
    end

#### Get users klout score

    Klout::Client.score("ladygaga", "davidguetta").map do |user|
      "#{user.twitter_screen_name}: #{user.kscore}"
    end

#### Get users klout profile

    Klout::Client.score("ladygaga", "davidguetta").map do |user|
      "#{user.twitter_screen_name}: #{user.score.true_reach}"
    end

#### Get users topics

    Klout::Client.topics("ladygaga", "davidguetta").map do |user|
      "#{user.twitter_screen_name}: #{user.topics.join(',')}"
    end

#### Get users influencers

    Klout::Client.influenced_by("ladygaga", "davidguetta").map do |user|
      "#{user.twitter_screen_name}: #{user.influencers.map { |i| i.twitter_screen_name }.join(',')}"
    end

#### Get users influencees

    Klout::Client.influencer_of("ladygaga", "davidguetta").map do |user|
      "#{user.twitter_screen_name}: #{user.influencees.map { |i| i.twitter_screen_name }.join(',')}"
    end

Performance
-----------

Klout-rb uses [multi_json](https://github.com/intridea/multi_json) for parsing JSON responses and [HTTPI](https://github.com/rubiii/httpi) for making HTTP requests.

You can use [yajl](https://github.com/brianmario/yajl-ruby) and [httpclient](https://github.com/nahi/httpclient) for better performance.

