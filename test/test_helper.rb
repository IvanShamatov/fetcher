# test_helper.rb
ENV['RACK_ENV'] = 'test'
require 'rubygems'
require 'httpi'
require 'concurrent-edge'
require 'minitest/autorun'
require 'webmock/minitest'

require File.expand_path("../../lib/npm.rb", __FILE__)