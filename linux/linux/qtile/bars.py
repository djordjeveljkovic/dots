from libqtile import bar
from libqtile.lazy import lazy
from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration

from colors import colors
from keybinds import defaultApps

#----------------------------------------------------------------------------
# Defaults and recurring settings
#----------------------------------------------------------------------------

widget_defaults = dict(
    font = "UbuntuMono Nerd Font Mono",
    fontsize = 12,
    padding = 0,
    background = colors[3],
    foreground = colors[0],
)

widgetDecorations = {
    "background": colors[0],
    "foreground": colors[1],
    "decorations": [
        RectDecoration(use_widget_background = True, radius = 12, filled = True, group = True),
    ],
}

barConfig = {
    "size":         20,
    "border_width": [0, 0, 0, 0],
    "border_color": [colors[3], colors[3], colors[3], colors[3]],
    "background": colors[3]
}



#----------------------------------------------------------------------------
# Main bar template
#----------------------------------------------------------------------------

barWidgets = [
    widget.GroupBox(
        spacing = 8,
        padding_x = 8,
        fontsize = 14,
        borderwidth = 0,
        inactive = colors[1],
        active = colors[1],
        this_current_screen_border = '#6C7086',
        highlight_method = 'block',
        rounded = True,
        **widgetDecorations,
    ),
    widget.Spacer(
        length = 10,
    ),
    widget.WindowName(
        format = "  {name}  ",
    ),
    widget.Spacer(
        length = bar.STRETCH,
    ),
    widget.Systray(
    ),
    widget.Spacer(
        length = 10,
    ),
    widget.Clock(
        format = "    %H:%M  ",
        **widgetDecorations,
    ),
    widget.Spacer(
        length = 10,
    ),
    widget.Clock(
        format = "     %d.%m.%Y  ",
	    mouse_callbacks={"Button1": lazy.spawn(defaultApps["terminal"] + " " + defaultApps["calendar"])},
        **widgetDecorations,
    ),
]



#----------------------------------------------------------------------------
# Declaration of bars
#
# System tray widget can be used only once
# It has to be deleted from the second bar
#----------------------------------------------------------------------------

mainBar = bar.Bar(barWidgets, **barConfig)
# secondBar = bar.Bar(barWidgets, **barConfig)
