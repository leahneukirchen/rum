# -*- ruby -*-
require '../lib/rum'

use Rack::ShowStatus

greeter = Rum.new {
  on param("name") do |name|
    res.write "Hello, #{Rack::Utils.escape_html name}!"
  end
  on default do
    res.write "Hello, world!"
  end
}

run Rum.new {
  on path('greet') do
    run greeter
  end
}
