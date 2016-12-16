#!/usr/bin/env bash
curl https://j.mp/spf13-vim3  -L -o - | sh
vim +BundleInstall! +BundleClean +q
