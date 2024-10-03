{ config, ... }:
{
  imports = [ ./config/os.nix ];
  programs.htop.enable = true;
  programs.htop.settings =
    {
      color_scheme = 0; # Custom color scheme
      theme_background = "#0F111A";
      theme_foreground = "#8F93A2";
      selected_bg_color = "#717CB4";
      selected_fg_color = "#FFFFFF";

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

      # Custom color mappings
      cpu_count_from_one = false;
      process_thread = "#82aaff"; # Blue
      process_thread_semaphore = "#c792ea"; # Purple
      process_thread_mutex = "#f07178"; # Red
      process_thread_cond = "#c3e88d"; # Green
      process = "#eeffff"; # White
      process_shadow = "#464B5D"; # Disabled color
      process_tag = "#ffcb6b"; # Yellow
      process_megabytes = "#f78c6c"; # Orange
      process_tree = "#717CB4"; # Gray
      process_R_fg = "#c3e88d"; # Green (Running)
      process_D_fg = "#f07178"; # Red (Disk sleep)
      process_S_fg = "#82aaff"; # Blue (Sleeping)
      process_Z_fg = "#ff5370"; # Error color (Zombie)
      process_T_fg = "#ffcb6b"; # Yellow (Traced)
      process_t_fg = "#f78c6c"; # Orange (Traced)
      process_I_fg = "#717CB4"; # Gray (Idle)

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
