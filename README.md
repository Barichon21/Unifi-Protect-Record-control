Here's an example of a well-structured `README.md` file for your Unifi script (registration control via API). It includes:

* A presentation
* Prerequisites
* Installation
* Usage
* Additional notes

---

````markdown
# Unifi Protect Record Control

This script enables you to activate or deactivate the recording of your **UniFi Protect** cameras via the API. It is designed to be integrated into automations (e.g. with Homebridge/HomeKit).

## 📦 Features

- Enable or disable recording for one or more cameras
- Simple command-line operation
- Can be integrated into home automation systems

---

## ✅ Prerequisites

- UniFi controller (UDM Pro, Cloud Key, etc.)
- Access to UniFi Protect API
- A username/password for an admin user (or at least a user with Protect access)
---

## 🛠️ Installation

1. Clone the repository:

``bash
git clone https://github.com/Barichon21/Unifi-Protect-Record-control.git
cd Unifi-Protect-Record-control
````

## ⚙️ Configuration

Modify the following variables directly in the script:

* `UNIFI_PROTECT_HOST` - IP address or DNS name of your UniFi controller
* `USERNAME` / `PASSWORD` - Your user credentials
* `CAMERA_ID` - ID of the target camera if you don't want to control everything

---

## ▶️ Usage

Command examples:

```bash
record.sh on
```

```bash
record.sh off
```

## 🧩 Integration with Homebridge / HomeKit

This script can be used in HomeKit automation via [Homebridge](https://homebridge.io/) with the [`homebridge-script2`] plugin (https://github.com/pponce/homebridge-script2).

---

## ❗ Warning

This script is not officially supported by Ubiquiti. Use it at your own risk. Do not use it on a production network without testing it first.
