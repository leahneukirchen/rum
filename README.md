# Rum, the gRand Unified Mapper

Rum is a powerful mapper for your Rack applications that can be used
as a microframework.  Just throw in a template engine and a data
backend, and get started!

## Mappings

Rum apps use a small DSL to set up the mappings:

    MyApp = Rum.new {
      on get, path('greet') do
        on param("name") do |name|
          puts "Hello, #{Rack::Utils.escape_html name}!"
        end
        on default do
          puts "Hello, world!"
        end
      end
    }

This will map GET /greet to the hello world, and GET /greet?name=X to
a personal greeting.

Mappings are declared by nested "on"-calls.  When one matched, the
block is called and other "on"-calls are ignored on that level.  (But
note you can use "also" to reset this.)

Multiple "on"-calls can be collapsed to one:

    on a do |x|
      on b do |y|
        ...
      end
    end

is the same as 

    on a, b do |x, y|
      ...
    end

Every predicate returns data which is passed to the block.  Use _ to
ignore data you don't need when using the collapsed calling method:

    on get, path('foo'), param('bar') do |_, _, bar| ... end

## Predicates

These predicates are predefined for your mappings:

path(rx): match rx against the PATH_INFO beginning and try to match a
  path segment.  (path('foo') will match '/foo/bar', but not '/foobar').
  PATH_INFO and SCRIPT_NAME are adjusted appropriately.

number: match a number segment in path.

segment: match any single segment in path.  (i.e. no '/'.)

extension(e=...): match (if given) and yield the file extension.

param(p, default=...): check if parameter p is given, else use default
  if passed.

header(p, default=...): check if HTTP header h exists, else yield default
  if passed.

default: always match.

host(h): check if the request was meant for host (useful for virtual
  servers).

method(m): check if the request used m as HTTP method.

get, post, put, delete: shortcuts for method(m).

accept(m): check if the request accepts MIME-type m.  This is a very
  simple check that doesn't handle parameters or globs for now.

check{block}: general check whether block returns a trueish value.

any(...): meta-predicate to check if any argument matches.

## Helpers

For convenience, Rum provides a few helpers:

env, req, res: The current Rack env, Rack::Request, Rack::Response.

also: Reset state of matching, that is, the next on() will be checked,
  even if one before already matched.

run(app): directly transfer to the Rack application app (which can be
  another Rum app.)

print, puts: wrappers for res.write.

## Copyright

Copyright (C) 2008, 2009 Christian Neukirchen <http://purl.org/net/chneukirchen>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Links

Rack:: <http://rack.rubyforge.org/>
Christian Neukirchen:: <http://chneukirchen.org/>


