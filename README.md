i3.cr
=====

A Crystal interface to the i3 window manager, using i3's
[IPC protocol](https://i3wm.org/docs/ipc.html).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  i3:
    github: woodruffw/i3.cr
```

## Usage

```crystal
require "i3"

# create a connection object and manage it manually
con = I3::Connection.new
con.subscribe("workspace")
con.command("workspace 1")
con.close

# or, let `act` do it for you:
I3.act do |con|
  con.command("workspace 1")
  sleep(0.1)
  con.command("workspace 2")
end
```

## TODO

* Figure out a way to expose events as callbacks (lack of threads makes this difficult)

## Contributing

1. Fork it (https://github.com/woodruffw/i3/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [woodruffw](https://github.com/woodruffw) William Woodruff - creator, maintainer
