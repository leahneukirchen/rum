# -*- ruby -*-
require '../lib/rum'

use Rack::ShowStatus

run Rum.new {
  on param("name") do |name|
    puts "Hello, #{Rack::Utils.escape_html name}!"
  end
  on default do
    puts "Hello, world!"
  end
}
