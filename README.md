# Astapor

A ruby port of https://github.com/garethr/serf-master

## Installation

Add this line to your application's Gemfile:

    gem 'astapor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install astapor

## Usage

Create a ~/handler.rb handler file like so:

```
#!/usr/bin/env ruby

require 'astapor'

class HelloHandler < Astapor::SerfHandler
    def hello_world
        puts "SOMEONE SAID HELLO with payload of #{ARGF.read}"
    end
end

class MemberJoinHandler < Astapor::SerfHandler
    def member_join
        puts "A member joined! Hello member!"
    end
end

handler = Astapor::SerfHandlerProxy.new
handler.register("responder", HelloHandler.new)
handler.register("default", MemberJoinHandler.new)
handler.run
```

Run serf agent:

```
serf agent -tag="role=default" -event-handler="~/handler.rb" -log-level=debug
```

you will see something like:

```
==> Starting Serf agent...
==> Starting Serf agent RPC...
==> Serf agent running!
         Node name: 'yourmachine.local'
         Bind addr: '0.0.0.0:7946'
          RPC addr: '127.0.0.1:7373'
         Encrypted: false
          Snapshot: false
           Profile: lan

==> Log data will now stream in as it occurs:

    2014/06/04 13:10:54 [INFO] agent: Serf agent starting
    2014/06/04 13:10:54 [INFO] serf: EventMemberJoin: yourmachine.local 10.200.17.37
    2014/06/04 13:10:55 [INFO] agent: Received event: member-join
    2014/06/04 13:10:55 [DEBUG] agent: Event 'member-join' script output: A member joined! Hello member!
```

exit serf agent and restart with:

```
serf agent -tag="role=responder" -event-handler="~/handler.rb" -log-level=d
```

you will see something like:

```
==> Starting Serf agent...
==> Starting Serf agent RPC...
==> Serf agent running!
         Node name: 'yourmachine.local'
         Bind addr: '0.0.0.0:7946'
          RPC addr: '127.0.0.1:7373'
         Encrypted: false
          Snapshot: false
           Profile: lan

==> Log data will now stream in as it occurs:

    2014/06/04 13:12:07 [INFO] agent: Serf agent starting
    2014/06/04 13:12:07 [INFO] serf: EventMemberJoin: yourmachine.local 10.200.17.37
    2014/06/04 13:12:08 [INFO] agent: Received event: member-join
    2014/06/04 13:12:08 [DEBUG] agent: Event 'member-join' script output: Astapor::SerfHandlerProxy: 2014-06-04 13:12:08 -0700: INFO: event member_join not implemented by HelloHandler class
```

Now issue a serf event from another terminal:

```
serf event hello_world world
```

You will see this in agent output:

```
    2014/06/04 13:13:33 [INFO] agent.ipc: Accepted client: 127.0.0.1:63048
    2014/06/04 13:13:33 [DEBUG] agent: Requesting user event send: hello_world. Coalesced: true. Payload: "world"
    2014/06/04 13:13:34 [INFO] agent: Received event: user-event: hello_world
    2014/06/04 13:13:34 [DEBUG] agent: Event 'user' script output: SOMEONE SAID HELLO with payload of world
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/astapor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request