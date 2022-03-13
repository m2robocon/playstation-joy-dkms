#!/bin/bash
dkms build -m @@PACKAGE@@/@@VERSION@@
dkms install -m @@PACKAGE@@/@@VERSION@@ --all
