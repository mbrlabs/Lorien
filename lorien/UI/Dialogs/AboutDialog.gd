class_name AboutDialog
extends Window

# -------------------------------------------------------------------------------------------------
func _ready():
	%VersionLabel.text = "Lorien v%s" % Config.VERSION_STRING
	size.y = $MarginContainer.size.y + 5
	close_requested.connect(hide)
	
	%GithubLinkButton.pressed.connect(func() -> void:
		OS.shell_open("https://github.com/mbrlabs/Lorien")
	)
	
	%LicenseButton.pressed.connect(func() -> void:
		OS.shell_open("https://github.com/mbrlabs/Lorien/blob/main/LICENSE")
	)
	
	%GodotButton.pressed.connect(func() -> void:
		OS.shell_open("https://godotengine.org/")
	)
	
	%KennyButton.pressed.connect(func() -> void:
		OS.shell_open("https://www.kenney.nl/assets/platformer-art-deluxe")
	)
	
	%RemixIconsButton.pressed.connect(func() -> void:
		OS.shell_open("https://remixicon.com/")
	)
