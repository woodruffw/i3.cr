require "json"

module I3
  # Represents the response to a `Message::MessageType::GET_VERSION` request.
  #
  # See `Connection#version`.
  class Message
    class Version
      JSON.mapping(
        major: Int32,
        minor: Int32,
        patch: Int32,
        human_readable: String,
        loaded_config_file_name: String,
      )
    end
  end
end
