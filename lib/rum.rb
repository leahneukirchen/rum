# rum - this router (the heart)
# soda - htemplate (plain and simple)
# lime - json db (the persistent)
# ice - ?

$: << "~/projects/rack/lib"
require 'rack'
require 'pp'

class Rum
  attr_reader :env, :req, :res

  def initialize(&blk)
    @blk = blk
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    @matched = false
    instance_eval(&@blk)
    @res.status = 404  unless @matched || !@res.empty?
    @res.finish
  end

  def on(*arg, &block)
    return  if @matched
    yield *arg.map { |a| a.call || return }
    @matched = true
  end

  def also
    @matched = false
  end

  def path(p)
    lambda {
      if env["PATH_INFO"] =~ /\A\/(#{p})(\/|\z)/   #/
        env["SCRIPT_NAME"] << "/#{$1}"
        env["PATH_INFO"] = $2 + $'
        $1
      end
    }
  end

  def number
    path("\\d+")
  end
  
  def segment
    path("[^\\/]+")
  end

  def extension(e="\\w+")
    lambda { env["PATH_INFO"] =~ /\.(#{e})\z/ && $1 }
  end

  def param(p, default=nil)
    lambda { req[p] || default }
  end

  def header(p, default=nil)
    lambda { env[p.upcase.tr('-','_')] || default }
  end

  def default
    lambda { true }
  end

  # def accept(mimetype, default=nil)
end

app = Rum.new do
  on path('foo') do
    res.write "in foo"
    pp env
    on path('bar') do
      res.write "and in bar"
    end
    on param('x', "99") do |x|
      res.write "got x with #{x}"
    end
    also
    on path("n"), number do |n|
      res.write "got #{n}"
    end
    also
    on path("hello") do
      on extension("txt"), segment do |_, name|
        res.write "HELLO, "
        res.write name
      end
      on extension("html"), segment do |_, name|
        p name
        res.write "<h1>hello, #{name}</h1>"
      end
      on extension, segment do |e, name|
        res.write "what is #{e}!?"
      end
      on default do
        res.write "meh"
      end
    end
  end
end


Rack::Handler::WEBrick.run Rack::ShowStatus.new(app), :Port => 9292
