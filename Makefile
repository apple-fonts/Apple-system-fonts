URL_DIR := url
DMG_DIR := dmg
FONTS_DIR := fonts

URL_FILES := $(shell ls $(URL_DIR)/*.url -1)
DMG_FILES := $(URL_FILES:$(URL_DIR)/%.url=$(DMG_DIR)/%.dmg)

FONT_NAMES := $(URL_FILES:$(URL_DIR)/%.url=%)
FONT_DIRS := $(FONT_NAMES:%=$(FONTS_DIR)/%)

FONTS_ZIP := fonts.zip

CHECK_PREREQUISITES_EXEC := check_prerequisites.sh
EXTRACT_EXEC := extract_fonts.sh

# check prerequisites
PREREQUISITES := "7z p7zip-full" "dmg2img"
define CHECK_PREREQUISITES :=
	@ret=0; \
	for i in $(PREREQUISITES); do \
		bash $(CHECK_PREREQUISITES_EXEC) $$i; \
		ret=$$(expr $$ret \| $$?); \
	done; \
	if [ $$ret -ne 0 ]; then \
		exit $$ret; \
	fi
endef

# build all
.PHONY: all
all: fonts

# .dmg files
.PHONY: dmg
dmg: $(DMG_FILES)

# download each .dmg file according to tue URLs provided in each .url file
$(DMG_DIR)/%.dmg: $(URL_DIR)/%.url
	@mkdir -p "$(dir $@)"
	@echo "[Downloading \"$@\"]"
	@cd "$(dir $@)"; wget -c --no-use-server-timestamps -i "$(CURDIR)/$<"

# extract fonts from .dmg files
.PHONY: fonts
fonts: $(FONT_DIRS)

# extract fonts from each .dmg into a directory
$(FONTS_DIR)/%: $(DMG_DIR)/%.dmg
	$(call CHECK_PREREQUISITES)
	@mkdir -p "$(dir $@)"
	bash "$(EXTRACT_EXEC)" "$<" "$@"

# pack all fonts into a .zip file
.PHONY: zip
zip: $(FONTS_ZIP)

$(FONTS_ZIP): $(FONT_DIRS)
	zip -r "$@" $(FONT_DIRS:%="%")

# cleanup
.PHONY: clean
clean: clean_fonts

.PHONY: clean_fonts
clean_fonts:
	-rm -rf "$(FONTS_DIR)"

.PHONY: clean_dmg
clean_dmg:
	-rm -rf "$(DMG_DIR)"

.PHONY: clean_zip
clean_zip:
	-rm -f "$(FONTS_ZIP)"

.PHONY: clean_all
clean_all: clean_fonts clean_dmg clean_zip
