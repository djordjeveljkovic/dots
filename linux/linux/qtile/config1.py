from libqtile import layout
from libqtile.config import Match, Screen

from bars import mainBar
from colors import colors
from keybinds import *

#----------------------------------------------------------------------------
# Layout settings
#----------------------------------------------------------------------------
    
layoutTheme = {
    "border_focus": colors[-2], 
    "border_normal": colors[0], 
    "border_width": 2, 
    "margin": 3
}


layouts = [
    layout.Columns(**layoutTheme),
]


floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="calcurse"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="nm-connection-editor"),
        Match(wm_class="whatsdesk"),
        Match(wm_class="caprine"),
        Match(wm_class="discord"),
    ],
    **layoutTheme
)



#----------------------------------------------------------------------------
# Screens settings
#----------------------------------------------------------------------------

screens = [
    Screen(
        top=mainBar,
    )
]



#----------------------------------------------------------------------------
# Miscelanous settings
#----------------------------------------------------------------------------

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = False

# If something Java related is not working, set this to "LG3D"
wmname = "Qtile"


