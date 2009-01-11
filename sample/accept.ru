# -*- ruby -*-
require '../lib/rum'

use Rack::ShowStatus

run Rum.new {
  on param("name") do |name|
    on any(accept("text/plain"), extension("txt")) do
      res.write "Hello, #{name}!"
    end
    on default do
      res.write "<h1>Hello, #{Rack::Utils.escape_html name}!</h1>"
    end
  end
  on default do
    res.write "Hello, world!"
  end
}
