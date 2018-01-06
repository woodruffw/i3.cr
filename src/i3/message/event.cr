require "json"

module I3
  class Message
    # A namespace for subscribed events.
    #
    # See `Message::EventType` and `Connection#subscribe`.
    module Event
      # Represents the `Message::EventType::WORKSPACE` event response.
      class Workspace
        JSON.mapping(
          change: String,
          current: Tree?,
          old: Tree?,
        )
      end

      # Represents the `Message::EventType::OUTPUT` event response.
      class Output
        JSON.mapping(
          change: String,
        )
      end

      # Represents the `Message::EventType::MODE` event response.
      class Mode
        JSON.mapping(
          change: String,
          pango_markup: Bool,
        )
      end

      # Represents the `Message::EventType::WINDOW` event response.
      class Window
        JSON.mapping(
          change: String,
          container: Tree,
        )
      end

      alias BarConfigUpdate = Bar

      # Represents the `Message::EventType::BINDING` event response.
      class Binding
        class Binding
          JSON.mapping(
            command: String,
            event_state_mask: Array(String),
            input_code: Int32,
            symbol: String?,
            input_type: String,
          )
        end

        JSON.mapping(
          change: String,
          binding: Binding,
        )
      end

      # Represents the `Message::EventType::SHUTDOWN` event response.
      class Shutdown
        JSON.mapping(
          change: String,
        )
      end
    end
  end
end
