class_name AboutDialog
extends PanelContainer

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	get_parent().close_requested.connect(get_parent().hide)
	%VersionLabel.text = "Lorien v%s" % Config.VERSION_STRING
	%GithubLinkButton.pressed.connect(func() -> void: OS.shell_open("https://github.com/mbrlabs/Lorien"))
	%LicenseButton.pressed.connect(func() -> void: OS.shell_open("https://github.com/mbrlabs/Lorien/blob/main/LICENSE"))
	%GodotButton.pressed.connect(func() -> void: OS.shell_open("https://godotengine.org/"))
	%KennyButton.pressed.connect(func() -> void: OS.shell_open("https://www.kenney.nl/assets/platformer-art-deluxe"))
	%RemixIconsButton.pressed.connect(func() -> void: OS.shell_open("https://remixicon.com/"))
