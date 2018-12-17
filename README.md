# collectd-iptables-accounting

A iptables plugin for [collectd](http://collectd.org)
using collectd's
[Python plugin](http://collectd.org/documentation/manpages/collectd-python.5.shtml).

## Install

1. Checkout this repository somewhere on your system accessible by
   collectd; for example as
   `/usr/share/collectd/collectd-iptables-accounting`.
1. Install the Python requirements with `pip install -r requirements.txt`.
1. Configure the plugin (see below).
1. Configure iptables (see init_iptables.sh and update_iptables.sh)
1. Restart collectd.

## Configuration

Add the following to your collectd config:

```
TypesDB "/usr/share/collectd/collectd-iptables-accounting/accounting.db"
LoadPlugin python

<Plugin python>
  ModulePath "/usr/share/collectd/collectd-iptables-accounting"
  Import "accounting"

  <Module accounting>
    CHAIN_NAMES "TRAFFIC_ACCT_OUT" "TRAFFIC_ACCT_IN"
  </Module>
</Plugin>
```

## Requirements

* python-dateutil
* python-iptables
