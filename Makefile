USER := $(shell whoami)

URL_DIR := url
DMG_DIR := dmg

FONTS_DIR := fonts
RELEASE_DIR := release

URL_FILES := $(shell ls $(URL_DIR)/*.url -1)
DMG_FILES := $(URL_FILES:$(URL_DIR)/%.url=$(DMG_DIR)/%.dmg)

FONT_NAMES := $(URL_FILES:$(URL_DIR)/%.url=%)
FONT_DIRS := $(FONT_NAMES:%=$(FONTS_DIR)/%)

SYSTEM_FONT_INSTALL_DIR := /usr/local/share/fonts
USER_FONT_INSTALL_DIR := $(HOME)/.local/share/fonts

ifeq ($(USER),root)
FONT_INSTALL_DIR := $(SYSTEM_FONT_INSTALL_DIR)
else
FONT_INSTALL_DIR := $(USER_FONT_INSTALL_DIR)
endif
FONT_INSTALL_DIR := $(FONT_INSTALL_DIR)/Apple

FONTS_ZIP := Apple-system-fonts.zip

CHECK_PREREQUISITES_EXEC := check_prerequisites.sh
EXTRACT_EXEC := extract_fonts.sh

# build all
.PHONY: all
all: fonts

# check all prerequisites
define CHECK_PREREQUISITES :=
	bash $(CHECK_PREREQUISITES_EXEC)
endef

# extract fonts from .dmg files
.PHONY: fonts
fonts: $(FONT_DIRS)

# .dmg files
.PHONY: dmg
dmg: $(DMG_FILES)

# download each .dmg file according to tue URLs provided in each .url file
$(DMG_DIR)/%.dmg: $(URL_DIR)/%.url
	$(eval URL_FILE = "$<")
	@mkdir -p "$(dir $@)"
	@echo "[Downloading \"$@\"]"
	@cd "$(dir $@)"; wget -c --no-use-server-timestamps -i "$(CURDIR)/$(URL_FILE)"

# extract fonts from each .dmg into a directory
$(FONTS_DIR)/%: $(DMG_DIR)/%.dmg
	$(call CHECK_PREREQUISITES)
	$(eval DMG_FILE = "$<")
	@mkdir -p "$(dir $@)"
	bash "$(EXTRACT_EXEC)" "$(DMG_FILE)" "$@"

# pack all fonts into a .zip file
.PHONY: zip
zip: $(FONTS_ZIP)

$(FONTS_ZIP): $(FONT_DIRS)
	zip -r "$@" $(FONT_DIRS:%="%")

# release
.PHONY: release
release: $(DMG_FILES) $(FONTS_ZIP)
	@mkdir -pv "$(RELEASE_DIR)"
	@for DMG_FILE in $(DMG_FILES); \
	do \
		ln -rsfv "$$DMG_FILE" "$(RELEASE_DIR)"; \
	done
	@ln -rsfv "$(FONTS_ZIP)" "$(RELEASE_DIR)"

# install fonts
.PHONY: install
install: fonts
	@mkdir -pv "$(FONT_INSTALL_DIR)"
	@cp -rfv "$(FONTS_DIR)"/* "$(FONT_INSTALL_DIR)"

# uninstall fonts
.PHONY: uninstall
uninstall:
	-rm -rfv "$(FONT_INSTALL_DIR)"

# cleanup
.PHONY: clean
clean: clean_release clean_zip clean_fonts

.PHONY: clean_all
clean_all: clean clean_dmg

.PHONY: clean_release
clean_release:
	-rm -rf "$(RELEASE_DIR)"

.PHONY: clean_zip
clean_zip: clean_release
	-rm -f "$(FONTS_ZIP)"

.PHONY: clean_fonts
clean_fonts:
	-rm -rf "$(FONTS_DIR)"

.PHONY: clean_dmg
clean_dmg: clean_release
	-rm -rf "$(DMG_DIR)"