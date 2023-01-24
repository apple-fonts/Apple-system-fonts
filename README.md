# Apple system fonts
This repository provides the fonts for the Apple system.

The fonts are extracted from the .dmg files, which can be obtained at https://developer.apple.com/fonts/.

The available fonts are:
* SF Pro
* SF Compact
* SF Mono
* SF Arabic
* New York

![](fonts-hero-large_2x.png)

## Prerequisites
These packages must be installed:
* `dmg2img`
* `p7zip-full`

## Download the `.dmg` files
* Download the `.dmg` files from [Apple's website](https://developer.apple.com/fonts/):
    ```bash
    make dmg -j
    ```

## Extract fonts
* Extract all fonts (will download the `.dmg` files first if not present):
    ```bash
    make -j
    ```
* Extract and pack all fonts into `fonts.zip`:
    ```bash
    make zip -j
    ```

## Clean up
* Clean up generated fonts (also removes the `fonts.zip` file):
    ```bash
    make clean
    ```
* Clean up the generated `fonts.zip` file:
    ```bash
    make clean_zip
    ```
* Clean up the `.dmg` files:
    ```bash
    make clean_dmg
    ```
* Clean up all of them:
    ```bash
    make clean_all
    ```

## See also
* [SF Symbols](https://github.com/mobiledesres/SF-Symbols)