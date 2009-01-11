require 'rack'

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
    catch(:rum_run_next_app) {
      instance_eval(&@blk)
      @res.status = 404  unless @matched || !@res.empty?
      return @res.finish
    }.call(env)
  end

  def on(*arg, &block)
    return  if @matched
    yield *arg.map { |a| a == true || (a != false && a.call) || return }
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
    true
  end

  def host(h)
    req.host == h
  end

  def method(m)
    req.request_method = m
  end

  def get; req.get?; end
  def post; req.post?; end
  def put; req.put?; end
  def delete; req.delete?; end

  # def accept(mimetype, default=nil)

  def run(app)
    throw :rum_run_next_app, app
  end
end
