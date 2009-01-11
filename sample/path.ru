# -*- ruby -*-
require '../lib/rum'

use Rack::ShowStatus

module Kernel
  def info(title, r)
    r.res['Content-Type'] = "text/plain"
    r.res.write "At #{title}\n"
    r.res.write "  SCRIPT_NAME: #{r.req.script_name}\n"
    r.res.write "  PATH_INFO: #{r.req.path_info}\n"
  end
end

run Rum.new {
  on path('foo') do
    info("foo", self)
    on path('bar') do
      info("foo/bar", self)
    end
  end
  also
  on default do
    info("default", self)
  end
}
