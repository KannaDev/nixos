{
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      # keys = {
      #   normal = {
      #     esc = [
      #       "collapse_selection"
      #       "keep_primary_selection"
      #     ];
      #     # Quick iteration on config changes
      #     C-o = ":config-open";
      #     C-r = ":config-reload";

      #     n = "move_char_left";
      #     i = "move_visual_line_up";
      #     e = "move_visual_line_down";
      #     o = "move_char_right";
      #     k = "insert_mode";

      #     h = "move_next_word_end"; # This was taken from the e key
      #     H = "move_next_long_word_end"; # This was taken from the e key

      #     K = [
      #       "goto_line_start"
      #       "insert_mode"
      #     ];

      #     I = "keep_selections";

      #     j = "search_next";
      #     J = "search_prev";

      #     l = "open_below";
      #     L = "open_above";

      #     #p = ["paste_clipboard_after", "collapse_selection"] #yippee normal behaviyor
      #     #P = ["paste_clipboard_before", "collapse_selection"]

      #     "space".w = {
      #       # Window Mode
      #       n = "jump_view_left";
      #       i = "jump_view_up";
      #       e = "jump_view_down";
      #       o = "jump_view_right";

      #       N = "swap_view_left";
      #       I = "swap_view_up";
      #       E = "swap_view_down";
      #       O = "swap_view_right";

      #       h = "hsplit";
      #     };

      #     "space".b = {
      #       # Buffer Mode
      #       b = "buffer_picker";
      #       n = "goto_previous_buffer";
      #       o = "goto_next_buffer";
      #       a = [
      #         ":new"
      #         "file_picker"
      #       ];

      #       d = ":buffer-close";
      #       q = ":buffer-close";
      #       c = ":buffer-close";
      #       D = ":buffer-close-others";
      #       Q = ":buffer-close-others";
      #       C = ":buffer-close-others";
      #     };

      #     g = {
      #       #goto
      #       n = "goto_line_start";
      #       o = "goto_line_end";
      #     };
      #   };
      #   select = {
      #     n = "extend_char_left";
      #     i = "extend_visual_line_up";
      #     e = "extend_visual_line_down";
      #     o = "extend_char_right";

      #     j = "extend_search_next";
      #     J = "extend_search_prev";

      #     k = "insert_mode";
      #     I = "keep_selections";
      #     #y = "yank_to_clipboard"
      #     #p = ["paste_clipboard_after", "collapse_selection"] #yippee normal behaviyor 
      #     #P = ["paste_clipboard_before", "collapse_selection"]
      #     g = {
      #       #goto
      #       n = "goto_line_start";
      #       o = "goto_line_end";
      #     };
      #   };
      # };
      editor = {
        mouse = true;
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        cursorcolumn = true;
        bufferline = "multiple";
        auto-completion = true;
        idle-timeout = 250;
        completion-timeout = 5;

        # jump-label-alphabet = "neioarstmgufywlphd,c.x/z;qjbkv";

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
          ];
          center = [
            "read-only-indicator"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
          ];
        };
      };
    };
  };

  # language config
  programs.helix.extraPackages = with pkgs; [
    vscode-langservers-extracted
    texlab
    marksman
    alejandra
    omnisharp-roslyn
    netcoredbg
    rust-analyzer
  ];

  programs.helix.languages = {
    language-server.nixd = {
      command = lib.getExe pkgs.nixd;
    };
    language = [
      {
        name = "nix";
        auto-format = false;
        indent = {
          tab-width = 2;
          unit = "  ";
        };
        diagnostic-severity = "Info";
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        language-servers = [ "nixd" ];
      }
    ];
  };
}
