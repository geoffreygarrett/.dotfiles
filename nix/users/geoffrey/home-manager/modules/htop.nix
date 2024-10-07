{ config, ... }:

let
  base16 = config.colorScheme.palette;
in
{
  imports = [ ./config/os.nix ];

  programs.htop.enable = true;
  programs.htop.settings =
    {
      color_scheme = 0; # Custom color scheme

      # Replacing the hardcoded colors with base16 values
      theme_background = "#${base16.base00}";
      theme_foreground = "#${base16.base04}";
      selected_bg_color = "#${base16.base06}";
      selected_fg_color = "#${base16.base07}";

      fields =
        with config.lib.htop.fields;
        if config.system.os != "android" then
          [
            PID
            USER
            PRIORITY
            NICE
            PERCENT_CPU
            PERCENT_MEM
            M_RESIDENT
            M_SHARE
            STATE
            ELAPSED
            COMM
          ]
        else
          [
            PID
            USER
            PERCENT_CPU
            PERCENT_MEM
            ELAPSED
            COMM
          ];

      header_margin = false;
      hide_kernel_threads = true;
      hide_userland_threads = false;
      highlight_base_name = true;
      highlight_megabytes = true;
      highlight_threads = true;
      shadow_other_users = false;
      show_cpu_frequency = true;
      show_cpu_usage = true;
      show_program_path = false;

      # Sorting configuration
      sort_key = config.lib.htop.fields.PERCENT_CPU;
      sort_direction = -1;
      tree_sort_key = config.lib.htop.fields.PERCENT_CPU;
      tree_sort_direction = -1;

      # View settings
      tree_view = false;
      tree_view_always_by_pid = false;

      # Thresholds and highlights
      highlight_changes = true;
      highlight_changes_delay_secs = 3;
      find_comm_in_cmdline = true;
      strip_exe_from_cmdline = true;
      show_merged_command = false;

      # Process hiding
      hide_function_bar = 0;

      # Custom color mappings using base16 colors
      cpu_count_from_one = false;
      process_thread = "#${base16.base0D}"; # Blue
      process_thread_semaphore = "#${base16.base0E}"; # Purple
      process_thread_mutex = "#${base16.base08}"; # Red
      process_thread_cond = "#${base16.base0B}"; # Green
      process = "#${base16.base05}"; # White
      process_shadow = "#${base16.base03}"; # Disabled color
      process_tag = "#${base16.base0A}"; # Yellow
      process_megabytes = "#${base16.base09}"; # Orange
      process_tree = "#${base16.base06}"; # Gray
      process_R_fg = "#${base16.base0B}"; # Green (Running)
      process_D_fg = "#${base16.base08}"; # Red (Disk sleep)
      process_S_fg = "#${base16.base0D}"; # Blue (Sleeping)
      process_Z_fg = "#${base16.base0F}"; # Error color (Zombie)
      process_T_fg = "#${base16.base0A}"; # Yellow (Traced)
      process_t_fg = "#${base16.base09}"; # Orange (Traced)
      process_I_fg = "#${base16.base06}"; # Gray (Idle)

      # Vim-style keybindings
      vim_mode = 1;
      move_up = "k";
      move_down = "j";
      move_left = "h";
      move_right = "l";
      tree_expand = "l";
      tree_collapse = "h";
    }
    // (
      with config.lib.htop;
      leftMeters (
        if config.system.os != "android" then
          [
            (bar "LeftCPUs4")
            (bar "Memory")
            (bar "Swap")
            (text "Tasks")
          ]
        else
          [
            (bar "CPU")
            (bar "Memory")
            (bar "Swap")
          ]
      )
    )
    // (
      with config.lib.htop;
      rightMeters (
        if config.system.os != "android" then
          [
            (bar "RightCPUs4")
            (text "LoadAverage")
            (text "DiskIO")
            (text "NetworkIO")
          ]
        else
          [
            (text "LoadAverage")
            (text "Tasks")
            (text "Uptime")
          ]
      )
    );
}
