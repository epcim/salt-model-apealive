#!/usr/bin/env python
import logging
import os
import usb.core
log = logging.getLogger(__name__)

def function():
    log.trace('Setting "usb_devices" grain value.')
    grains = {}
    devices = []
    dev = usb.core.find(find_all=True)
    for cfg in dev:
        if cfg._manufacturer is None:
            cfg._manufacturer = usb.util.get_string(cfg, cfg.iManufacturer)
        if cfg._product is None:
            cfg._product = usb.util.get_string(cfg, cfg.iProduct)
        devices.append({
            'manufacturer': str(cfg._manufacturer),
            'product': str(cfg._product),
            'manufacturer': str(cfg.manufacturer),
            'device_class': cfg.bDeviceClass,
            'device_subclass': cfg.bDeviceSubClass,
            'bus': str(cfg.bus),
            'address': str(cfg.address),
            'vendor_id': hex(cfg.idVendor),
            'product_id': hex(cfg.idProduct)
        })
    grains['usb_devices'] = devices
    return grains
