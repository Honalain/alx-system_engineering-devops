#!/usr/bin/env ruby
#Ruby script that accepts one argument and pass it to a regular expression matching method that start with h annd end with n
#Regex do not contain square brackets
puts ARGV[0].scan(/h.n/).join
