require "json"

module I3
  class Message
    # Represents the response to a `Message::MessageType::GET_BAR_CONFIG` request.
    #
    # See `Connection#bar_config`.
    class Bar
      class Colors
        JSON.mapping(
          background: String?,
          statusline: String?,
          separator: String?,
          focused_background: String?,
          focused_statusline: String?,
          focused_separator: String?,
          focused_workspace_text: String?,
          focused_workspace_bg: String?,
          focused_workspace_border: String?,
          active_workspace_text: String?,
          active_workspace_bg: String?,
          active_workspace_border: String?,
          inactive_workspace_text: String?,
          inactive_workspace_bg: String?,
          inactive_workspace_border: String?,
          urgent_workspace_text: String?,
          urgent_workspace_bg: String?,
          urgent_workspace_border: String?,
          binding_mode_text: String?,
          binding_mode_bg: String?,
          binding_mode_border: String?,
        )
      end

      JSON.mapping(
        id: String,
        mode: String,
        position: String,
        status_command: String,
        font: String,
        workspace_buttons: Bool,
        binding_mode_indicator: Bool,
        verbose: Bool,
        colors: Colors,
      )
    end
  end
end
