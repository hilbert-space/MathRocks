#!/usr/bin/env ruby

require 'progressbar'

netlist = ARGV[0]
raise 'The first argument should be a netlist.' if netlist.nil? || netlist.empty?

Lcount = ARGV[1].to_i
raise 'The second argument should be the number of L measurements.' if Lcount <= 0

Tcount = ARGV[2].to_i
raise 'The third argument should be the number of T measurements.' if Tcount <= 0

netlist_out = ARGV[3]
if netlist_out.nil? || netlist_out.empty?
  raise 'The fourth argument should be the output file.'
end

netlist_tmp = "#{ netlist }_tmp"

dir = File.dirname(__FILE__)

netlist = File.open(File.join dir, netlist).read

unless netlist.match /^\s*.param\s+L\s*=\s*(\d+)n.*$/
  raise 'Cannot find the channel length.'
end

#
# Channel length
#

Lnom = $1.to_i * 1e-9
Ldev = 0.05 * Lnom

Lmin = Lnom - Ldev
Lrange = 2 * Ldev

if Lcount == 1
  L = [ Lnom ]
else
  L = Array.new(Lcount)

  (0...Lcount).to_a.each do |i|
    L[i] = "%.4e" % (Lmin + i * Lrange / (Lcount - 1))
  end
end

#
# Temperature
#

Tnom = 27

Tmin = Tnom
Trange = 100 - Tmin

if Tcount == 1
  T = [ Tnom ]
else
  T = Array.new(Tcount)

  (0...Tcount).to_a.each do |i|
    T[i] = "%.2f" % (Tmin + i * Trange / (Tcount - 1))
  end
end

#
# Simulation
#

output = File.open(netlist_out, 'w')

output.puts "L\tT\tI"

pb = ProgressBar.new('Ngspice', L.length * T.length);

L.each do |l|
  T.each do |t|
    netlist0 = netlist.gsub(/L\s*=\s*[^\s]+/, "L = #{ l }")
    netlist0 = netlist0.gsub(/Temp\s*=\s*[^\s]+/, "Temp = #{ t }")

    File.open(File.join(dir, netlist_tmp), 'w') { |f| f.write netlist0 }
    pipe = IO.popen("cd #{ dir } && ngspice -b #{ netlist_tmp } 2> /dev/null")
    lines = pipe.readlines
    pipe.close

    lines.each do |line|
      next unless line.match /^isub\s*=\s*(.*)/
      output.puts "%.4e\t%.2f\t%.6e" % [ l, t, $1.to_f.abs ]
    end

    pb.inc
  end
end

puts

output.close

File.delete File.join(dir, netlist_tmp) rescue true
File.delete File.join(dir, 'bsim4.out') rescue true
