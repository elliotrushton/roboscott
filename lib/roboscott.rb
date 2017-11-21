#!/usr/bin/env ruby

require 'yaml'

module Logging
  ESCAPES = { :green  => "\033[32m",
              :yellow => "\033[33m",
              :red    => "\033[31m",
              :reset  => "\033[0m" }

  def error(message)
    emit(:message => message, :color => :red)
  end

  def emit(opts={})
    color   = opts[:color]
    message = opts[:message]
    print ESCAPES[color]
    print message
    print ESCAPES[:reset]
    print "\n"
  end
end

class RoboScott
  include Logging

  def initialize(file, config={})
    @file = file
    @config = config
  end

  def do_lint
    unless File.exists? @file
      error "File #{@file} does not exist"
      return 0
    else
      if File.directory? @file
        return self.parse_directory @file
      else
        return self.parse_file @file
      end
    end
  end

  def parse_directory(directory)
    Dir.glob("#{directory}/*").inject(0) do |mem, fdir|
      if File.directory? fdir
        mem + parse_directory(fdir)
      else
        mem + parse_file(fdir)
      end
    end
  end

  def parse_file(file)
    if (not File.extname(file) =~ /.(yaml|yml)$/) && (not @config[:nocheckfileext])
      # Instead of logging an error, just silently move on. Helps us scan a repo
      return 1
    end
    begin
      yaml = YAML.load_file(file)
    rescue Exception => err
      # Not a yaml file, move on, nothing to see here
      return 1
    else
      traverse(file, yaml ) do |node|
        #puts node
      end
      return 0
    end
  end

  def has_keys?(yaml)
    has_fails = false
    yaml.each do |key, value|
      puts "Key: #{key}"
      if key_looks_important?(key) and value_looks_sensitive?(value)
        has_fails = true
        report_fail(key, value)
      end
    end
    return has_fails
  end

  def key_looks_important?(key)
    if key.class != String
      return false
    end

    # TODO - move bad_words to a config value
    bad_words = ['SECRET', 'TOKEN', 'PASSWORD', 'KEY']
    bad_words.each do |baddy|
      if key.upcase.include? baddy
        return true
      end
    end
    return false
  end

  def value_looks_sensitive?(val)
    if val == nil or val == ''
      return false
    end

    # TODO - move okay_vals to a config value
    okay_vals = ['ENV', 'DUMMY']
    okay_vals.each do |ok|
      if val.upcase.include? ok
        return false
      end
    end
    rescue
      return false
    return true
  end

  def report_fail(file, key, value, redacted=true)
    value = 'REDACTED' unless @config[:unredacted]

    error "File #{file} - The value '#{value}' for key '#{key}' looks sensitive"
  end

  def traverse(filename, obj, &blk)
    case obj
    when Hash
      obj.each {|key, val|
      if val.class == Hash
        traverse(filename, val, &blk)
      else
        # In this case the value should be a leaf node (not another hash)
        if key_looks_important?(key) and value_looks_sensitive?(val)
          has_fails = true
          report_fail(filename, key, val)
        end
      end
      }
    when Array
      obj.each {|v| traverse(filename, v, &blk) }
    else
      blk.call(obj)
    end
  end
end
