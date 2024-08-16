extends WindowDialog

# -------------------------------------------------------------------------------------------------
func _ready():
	rect_size.y = $MarginContainer.rect_size.y + 5
	$"%VersionLabel".text = "Lorien v%s" % Config.VERSION_STRING
	
	$"%GithubLinkButton".connect("pressed", self, "_on_GithubLinkButton_pressed")
	$"%LicenseButton".connect("pressed", self, "_on_LicenseButton_pressed")
	$"%GodotButton".connect("pressed", self, "_on_GodotButton_pressed")
	$"%KennyButton".connect("pressed", self, "_on_KennyButton_pressed")
	$"%RemixIconsButton".connect("pressed", self, "_on_RemixIconsButton_pressed")

# -------------------------------------------------------------------------------------------------
func _on_GithubLinkButton_pressed():
	OS.shell_open("https://github.com/mbrlabs/Lorien")

# -------------------------------------------------------------------------------------------------
func _on_LicenseButton_pressed():
	OS.shell_open("https://github.com/mbrlabs/Lorien/blob/main/LICENSE")

# -------------------------------------------------------------------------------------------------
func _on_GodotButton_pressed():
	OS.shell_open("https://godotengine.org/")

# -------------------------------------------------------------------------------------------------
func _on_RemixIconsButton_pressed():
	OS.shell_open("https://remixicon.com/")

# -------------------------------------------------------------------------------------------------
func _on_KennyButton_pressed():
	OS.shell_open("https://www.kenney.nl/assets/platformer-art-deluxe")
