#!/usr/bin/env python
import logging
import os
log = logging.getLogger(__name__)

def function():
    log.trace('Setting "machine_model" grain value.')
    grains = {}
    if os.path.exists("/sys/firmware/devicetree/base/model"):
        with open("/sys/firmware/devicetree/base/model", 'r') as grain:
            grains['machine_model'] = grain.read()
    else:
        grains['machine_model'] = ""
    return grains
