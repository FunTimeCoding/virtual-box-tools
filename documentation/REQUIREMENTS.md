# Requirements

- Do not use the VirtualBox host-only network feature. This configuration appears to cause a routing problem preventing the host to connect to virtual machines after a reboot, but starts working again some hours later.
- Do not use the VirtualBox auto-start and stop feature. The stop feature appears to power-off and not trigger an ACPI power-button event which leads to a routing problem after a reboot.
