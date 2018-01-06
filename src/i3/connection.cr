require "socket"

module I3
  # Represents a connection to a local i3 IPC server.
  class Connection
    private alias MType = Message::MessageType
    private alias EType = Message::EventType

    # The path to the socket being used for the connection.
    getter socket_path : String

    # The `UNIXSocket` being communicated over.
    private getter socket : UNIXSocket

    # The `Channel`s being used for message dispatch.
    private getter requests : Channel(Message)
    private getter replies : Channel(Message)
    private getter events : Channel(Message)

    # Creates a new `Connection`.
    #
    # Raises an `Error` if the connection can't be created.
    def initialize
      @socket_path = `i3 --get-socketpath`.chomp
      raise Error.new("Could not get socket path") unless $?.success?

      @socket = UNIXSocket.new(@socket_path)

      @requests = Channel(Message).new
      @replies = Channel(Message).new
      @events = Channel(Message).new

      pump_requests!
      pump_responses!
    end

    # Close this instance's connection to the IPC server.
    def close
      socket.close
    end

    # Send an (i3) command to i3.
    #
    # Returns an array of `Message::Status` indicating the success of the commands.
    #
    # ```
    # # send a single command
    # con.command "sticky enable"
    #
    # # send two commands
    # con.command "workspace 1; sticky enable"
    # ```
    def command(cmd)
      Array(Message::Status).from_json(send_with_reply(Message.new(MType::RUN_COMMAND, cmd)).payload)
    end

    # Returns an array of all `Message::Workspace`s known to i3.
    def workspaces
      Array(Message::Workspace).from_json(send_with_reply(Message.new(MType::GET_WORKSPACES)).payload)
    end

    # Subscribe to each event in *event_names*.
    #
    # Events can be retrieved one-at-a-time via `#on_event`.
    #
    # ```
    # con.subscribe ["workspace", "output"]
    # ```
    def subscribe(event_names : Enumerable(String))
      Message::Status.from_json(send_with_reply(Message.new(MType::SUBSCRIBE, event_names.to_json)).payload)
    end

    # Subscribe to a single event.
    #
    # Events can be retrieved one-at-a-time via `#on_event`.
    #
    # ```
    # con.subscribe "workspace"
    # ```
    def subscribe(event_name : String)
      subscribe([event_name])
    end

    # Yields the last unconsumed event (see classes in `Message::Event`).
    #
    # Events are yielded in FIFO order.
    #
    # ```
    # con.on_event do |event|
    #   # check the actual event type
    # end
    # ```
    def on_event(&block)
      msg = events.receive

      event = case msg.type.as(EType)
              when .workspace?
                Message::Event::Workspace.from_json(msg.payload)
              when .output?
                Message::Event::Output.from_json(msg.payload)
              when .mode?
                Message::Event::Mode.from_json(msg.payload)
              when .window?
                Message::Event::Window.from_json(msg.payload)
              when .barconfig_update?
                Message::Event::BarConfigUpdate.from_json(msg.payload)
              when .binding?
                Message::Event::Binding.from_json(msg.payload)
              when .shutdown?
                Message::Event::Shutdown.from_json(msg.payload)
              else
                raise Error.new("unknown event message received: #{msg}")
              end

      yield event
    end

    # Returns an array of all `Message::Output`s known to i3.
    def outputs
      Array(Message::Output).from_json(send_with_reply(Message.new(MType::GET_OUTPUTS)).payload)
    end

    # Returns a `Message::Tree` corresponding to the current i3 window tree.
    def tree
      Message::Tree.from_json(send_with_reply(Message.new(MType::GET_TREE)).payload)
    end

    # Returns an array of strings for each container that has a mark.
    def marks
      Array(String).from_json(send_with_reply(Message.new(MType::GET_MARKS)).payload)
    end

    # Returns an array of strings, each identifying an i3 bar.
    #
    # Elements of this array can be fed into `#bar_config`.
    def bar_ids
      Array(String).from_json(send_with_reply(Message.new(MType::GET_BAR_CONFIG)).payload)
    end

    # Returns a `Message::Bar` corresponding to the given bar ID.
    #
    # Bar IDs can be retrieved via `#bar_ids`.
    #
    # ```
    # # get the config for the first bar
    # con.bar_config(con.bar_ids.first)
    # ```
    def bar_config(bar)
      Message::Bar.from_json(send_with_reply(Message.new(MType::GET_BAR_CONFIG, bar)).payload)
    end

    # Returns a `Message::Version` corresponding to i3's version information.
    def version
      Message::Version.from_json(send_with_reply(Message.new(MType::GET_VERSION)).payload)
    end

    # Returns an array of strings, each signifying a currently configured binding mode.
    def binding_modes
      Array(String).from_json(send_with_reply(Message.new(MType::GET_BINDING_MODES)).payload)
    end

    # Returns a `Message::Config` corresponding to the running i3's most recent configuration.
    def config
      Message::Config.from_json(send_with_reply(Message.new(MType::GET_CONFIG)).payload)
    end

    # Sends a `Message` as a request, and retrieves the corresponding reply as a new `Message`.
    private def send_with_reply(msg)
      requests.send(msg)
      replies.receive
    end

    # Pumps request `Message`s sent over the channel to the i3 IPC socket.
    private def pump_requests!
      spawn do
        until socket.closed?
          msg = requests.receive
          socket.write_bytes(msg)
        end
      end
    end

    # Pumps response `Message`s sent over the i3 IPC socket to the event and reply channels.
    private def pump_responses!
      spawn do
        until socket.closed?
          msg = socket.read_bytes(Message)

          if msg.event?
            events.send(msg)
          else
            replies.send(msg)
          end
        end
      end
    end
  end
end
