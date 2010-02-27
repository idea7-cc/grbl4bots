require 'rubygems'
require 'optparse'
require 'serialport'


options_parser = OptionParser.new do |opts|
  opts.banner = "Usage: stream [options] gcode-file"
  opts.on('-v', '--verbose', 'Output more information') do
    $verbose = true
  end   

  opts.on('-p', '--prebuffer', 'Prebuffer commands') do
    $prebuffer = true
  end   
  
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end
options_parser.parse!
if ARGV.empty?
  puts options_parser
  exit
end

SerialPort.open('/dev/tty.usbserial-A9007QcR', 9600) do |sp|
  sp.write("\r\n\r\n");
  sleep 5
  ARGV.each do |file|
    puts "Processing file #{file}"
    prebuffer = $prebuffer ? 7 : 0
    File.readlines(file).each do |line|
      next if line.strip == ''
      puts line.strip
      sp.write("#{line.strip}\r\n");
      if prebuffer == 0
        sleep 0.1
        begin
          result = sp.gets.strip
          puts "Grbl >> #{result}" unless result == '' or result == 'ok'
        end while result != 'ok'
      else
        prebuffer -= 1
      end
    end
  end
end