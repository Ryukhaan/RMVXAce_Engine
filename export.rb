#! /usr/bin/env ruby
# encoding: utf-8
#
# Script to export the scripts inside the Scripts.rvdata2 data file to Data/exported_scripts as plain text Ruby files.
# If you run this script from inside RPG Maker VX Ace, I would suggest creating the Data/exported_scripts folder yourself
# as RGSS3 doesn't seem to support requiring FileUtils.
# Based on HIRATA Yasuyuki / 平田 泰行's rvdata2_dump.rb script: https://gist.github.com/hirataya/1853033
begin
  require 'fileutils'
  require "zlib"
rescue LoadError
  puts "Can't load fileutils or zlib; ensure that the Data/exported_scripts folder has been created"
end

#class Exporter

def export_scripts():
  path = File.join("Data", "exported_scripts")
  FileUtils.mkdir_p(path) if defined?(FileUtils)
  puts "Starting"
  counter = 0
  Marshal.load(File.binread(File.join("Data", "Scripts.rvdata2"))).each.with_index do |cont, index|
    id, name, code = cont
    code = Zlib::Inflate.inflate(code).force_encoding("utf-8")
    next if id.nil?
    if code.size == 0
      puts "Skipping [#{index}] #{id} #{name}"
      next
    end
    
    puts "Exporting [#{index}] ##{id}: #{name} to #{File.join(path, "#{name}.rb")}"
    File.open(File.join(path, "#{name}.rb"), "wb") do |f| 
      # Error occurs in RMVX Ace when script have this header
      #f.puts "# encoding: utf8"
      f.puts "# [#{index}] #{id}: #{name}"
      f.write code
    end
    counter +=1
  end
  puts "#{counter} files successfully exported."
rescue Exception => e
  p e
end


export_scripts()