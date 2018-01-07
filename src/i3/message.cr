require "./message/*"

module I3
  # Represents a message exchanged during a `Connection`.
  #
  # `Message` instances are of one of the following types:
  # * `MessageType` - sent by the client to the i3 IPC server
  # * `ReplyType` - sent by the i3 IPC server to the client as a response
  # * `EventType` - sent by the i3 IPC server to the client as an event
  class Message
    alias Fmt = IO::ByteFormat::SystemEndian

    # The magic bytes that identify all i3 IPC messages.
    MAGIC = "i3-ipc"

    # All possible message types.
    enum MessageType
      RUN_COMMAND
      GET_WORKSPACES
      SUBSCRIBE
      GET_OUTPUTS
      GET_TREE
      GET_MARKS
      GET_BAR_CONFIG
      GET_VERSION
      GET_BINDING_MODES
      GET_CONFIG
    end

    # This is a convenience alias, since reply types are identical to message types.
    alias ReplyType = MessageType

    # All possible event types.
    enum EventType
      WORKSPACE
      OUTPUT
      MODE
      WINDOW
      BARCONFIG_UPDATE
      BINDING
      SHUTDOWN
    end

    # The type of the message.
    getter type : MessageType | ReplyType | EventType

    # The size of the message, in bytes.
    getter size : Int32

    # The message's payload, as a string.
    getter payload : String

    # Creates a new instance of `Message` from the given `IO`.
    #
    # Raises an `Error` on any parsing failure.
    def self.from_io(io, format = Fmt)
      magic = io.gets(MAGIC.size)

      raise Error.new("missing or malformed message magic") unless magic && magic == MAGIC

      size = io.read_bytes Int32, format
      typeno = io.read_bytes Int32, format
      payload = io.gets(size)

      type = if (typeno >> 31).zero?
               MessageType.new(typeno)
             else
               EventType.new(typeno & 0x7F)
             end

      raise Error.new("missing or malformed payload") unless payload && payload.bytesize == size

      new(type, payload)
    end

    # Creates a new `Message` with the given *type* and *payload*.
    def initialize(@type, @payload = "")
      @size = @payload.size
    end

    # Returns whether the current message is an event.
    def event?
      type.class == EventType
    end

    # Writes this instance to the given `IO`, in the format used by i3.
    def to_io(io, format = Fmt)
      io << MAGIC
      io.write_bytes size, format
      io.write_bytes type.to_i, format
      io << payload
    end

    # Write a human-friendly representation of this `Message` to the given IO.
    def to_s(io)
      io << "#{type}: #{payload} (#{size})"
    end
  end
end
