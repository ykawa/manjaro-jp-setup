local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  local gui_window = window:gui_window()

  -- OS別の最大化処理
  if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
    -- macOS: window_decorations設定に関わらず確実に最大化
    wezterm.time.call_after(0.1, function()
      gui_window:set_position(0, 22) -- macOSメニューバーの下に配置
      local screen = wezterm.gui.screens().main
      gui_window:set_inner_size(screen.width, screen.height - 22) -- メニューバー分を調整
    end)
  else
    -- Linux/Windows: 通常の最大化
    gui_window:maximize()
  end
end)

local config = {
  -- 基本設定
  term = 'xterm-256color',
  font = wezterm.font_with_fallback{
    { family = 'Source Han Code JP R', weight = 'Regular', italic = false },
    { family = 'M+1Code Nerd Font', weight = 'Regular', italic = false },
    { family = 'Fira Code', weight = 'Regular', italic = false },
    { family = 'Cica' },
    { family = 'Cica', assume_emoji_presentation = true },
  },
  font_size = 12.0,
  line_height = 1.0,
  enable_scroll_bar = true,
  scrollback_lines = 100000,
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  default_cursor_style = 'BlinkingBlock',
  cursor_blink_rate = 600,
  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',
  animation_fps = 1,
  audible_bell = 'Disabled',

  -- IME
  use_ime = true,
  xim_im_name = 'fcitx',
  ime_preedit_rendering = 'Builtin',

  -- ウィンドウ設定
  window_padding = { left = 2, right = 16, top = 0, bottom = 0 },

  -- カラースキーム設定
  color_scheme = 'Dracula',
  colors = {
    tab_bar = {
      inactive_tab_edge = '#00a0e4',
      active_tab = {
        bg_color = '#003784', fg_color = '#00a0e4',
        intensity = 'Normal', underline = 'None', italic = false, strikethrough = false,
      },
    },
    scrollbar_thumb = '#003784',
    cursor_bg = '#00a0e4',
    cursor_fg = '#003784',
    cursor_border = '#003784',
  },

  -- ウィンドウフレーム設定
  window_frame = {
    font = wezterm.font { family = 'Meiryo', weight = 'Regular', italic = false },
    font_size = 11.0,
  },

  -- OS別のウィンドウ設定
  window_decorations = (wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin') and 'RESIZE' or 'None',
  window_background_opacity = (wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin') and 0.85 or 0.60,
  macos_window_background_blur = 20,
  native_macos_fullscreen_mode = false,

  -- インアクティブペインの外観
  inactive_pane_hsb = { saturation = 0.9, brightness = 0.8, },

  -- Disable updates
  check_for_updates = false,
  show_update_window = false,

  -- キーバインド設定
  keys = {
    { key = '1', mods = 'ALT', action = wezterm.action { ActivateTab = 0 } },
    { key = '2', mods = 'ALT', action = wezterm.action { ActivateTab = 1 } },
    { key = '3', mods = 'ALT', action = wezterm.action { ActivateTab = 2 } },
    { key = '4', mods = 'ALT', action = wezterm.action { ActivateTab = 3 } },
    { key = '5', mods = 'ALT', action = wezterm.action { ActivateTab = 4 } },
    { key = '6', mods = 'ALT', action = wezterm.action { ActivateTab = 5 } },
    { key = '7', mods = 'ALT', action = wezterm.action { ActivateTab = 6 } },
    { key = '8', mods = 'ALT', action = wezterm.action { ActivateTab = 7 } },
    { key = '9', mods = 'ALT', action = wezterm.action { ActivateTab = 8 } },
    { key = '0', mods = 'ALT', action = wezterm.action { ActivateTab = 9 } },
    { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },
    { key = 'Delete', mods = 'CTRL', action = wezterm.action.SendKey { key = 'd', mods = 'ALT', } },
    { key = 'Backspace', mods = 'CTRL', action = wezterm.action.SendKey { key = 'w', mods = 'CTRL', } },
    { key = 'LeftArrow', mods = 'CTRL', action = wezterm.action.SendKey { key = 'b', mods = 'ALT', } },
    { key = 'RightArrow',mods = 'CTRL', action = wezterm.action.SendKey { key = 'f', mods = 'ALT', } },
    { key = ',', mods = 'CTRL', action = wezterm.action { SpawnCommandInNewWindow = { args = { 'cursor', os.getenv('HOME') .. '/.wezterm.lua' } } } },
  },

  -- 選択時の単語区切り設定
  selection_word_boundary = " '\"{}[](),",
}

return config
