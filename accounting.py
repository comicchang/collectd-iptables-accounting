#!/usr/bin/env python
# -*- encoding: utf-8 -*-


import dateutil.parser
import time
import datetime
import platform
import copy
import iptc
import sys
import os
import pickle

class Stats:
    @classmethod
    def emit(cls, chain_name, type, value, t=None, type_instance=None):
        val = collectd.Values()
        val.plugin = 'accounting'
        val.plugin_instance = chain_name

        if type:
            val.type = type
        if type_instance:
            val.type_instance = type_instance

        if t:
            val.time = time.mktime(dateutil.parser.parse(t).timetuple())
        else:
            val.time = time.time()

        # With some versions of CollectD, a dummy metadata map must to be added
        # to each value for it to be correctly serialized to JSON by the
        # write_http plugin. See
        # https://github.com/collectd/collectd/issues/716
        val.meta = {'true': 'true'}

        val.values = value
        val.dispatch()

    @classmethod
    def read(cls, container, stats, t):
        raise NotImplementedError

class TrafficStats(Stats):
    @classmethod
    def read(cls, chain_name, raw_data, t = None):

        if not chain_name in total_traffic:
            # empty dataset, insert the first one
            collectd.info('Accounting: init values for ' + chain_name)
            diff_data = raw_data
        else:
            # diff from last time
            old_data = total_traffic[chain_name]
            new_data = raw_data

            diff_data = copy.deepcopy(new_data)
            for key in new_data.keys():
                if key in old_data:
                    if new_data[key] > old_data[key]:
                        diff_data[key] = new_data[key] - old_data[key]

        total_traffic[chain_name] = raw_data

        for key in diff_data.keys():
            cls.emit(chain_name, 'traffic', [diff_data[key]], t=None, type_instance=key)


class accounting:
    """
    CollectD plugin for collecting iptables traffic
    """
    DEFAULT_CHAIN_NAMES = ['ACCOUNTING_INPUT_CHAIN', 'ACCOUNTING_OUTPUT_CHAIN']

    def __init__(self, chain_names=None):
        self.chain_names = chain_names or accounting.DEFAULT_CHAIN_NAMES
        self.stats = {}


    def configure_callback(self, conf):
        for node in conf.children:
            if node.key == 'CHAIN_NAMES':
                self.chain_names = node.values
                collectd.info('Accounting: Starting stats gathering for ' + ', '.join (self.chain_names))

    def init_callback(self):
        collectd.register_read(self.read_callback)
        return True

    def read_callback(self):
        chain_names = self.chain_names

        for chain_name in chain_names:
            # Get and process stats from the iptable chains.
            rawData = getRawData(chain_name)
            TrafficStats.read (chain_name, rawData)

        # save the new data 
        f = open('accounting.pickle', 'wb')
        pickle.dump(total_traffic, f)
        f.close()


def getRawData (chain_name):
    if True:
        table = iptc.Table(iptc.Table.FILTER)
        chain = iptc.Chain(table, chain_name)
        table.refresh() 
        raw_data = {}
        for rule in chain.rules:
            (junk, bytes) = rule.get_counters()
            if (rule.src.split('/')[1]  == "255.255.255.255"):
                host = rule.src.split('/')[0] 
            else:
                host = rule.dst.split('/')[0]
            raw_data[host] = bytes

    return raw_data

# Command-line execution
if __name__ == '__main__':
    class ExecCollectdValues:
        def dispatch(self):
            if not getattr(self, 'host', None):
                self.host = os.environ.get('COLLECTD_HOSTNAME', 'localhost')
            identifier = '%s/%s' % (self.host, self.plugin)
            if getattr(self, 'plugin_instance', None):
                identifier += '-' + self.plugin_instance
            identifier += '/' + self.type
            if getattr(self, 'type_instance', None):
                identifier += '-' + self.type_instance
            print ('PUTVAL', identifier, \
                  ':'.join(map(str, [int(self.time)] + self.values)))

    class ExecCollectd:
        def Values(self):
            return ExecCollectdValues()

        def warning(self, msg):
            print ('WARNING:', msg)

        def info(self, msg):
            print ('INFO:', msg)

        def register_read(self, docker_plugin):
            pass

    collectd = ExecCollectd()
    plugin = accounting()

    try:
        f = open('accounting.pickle', 'rb')
        total_traffic = pickle.load(f)
        collectd.info("load successful")
    except:
        total_traffic = {}
        collectd.info("load failed")

    try:
        close (f)
    except:
        pass


    if len(sys.argv) > 1:
        plugin.chain_names = sys.argv[1:]

    if plugin.init_callback():
        plugin.read_callback()

# Normal plugin execution via CollectD
else:
    import collectd
    try:
        #why???
        f = open('/var/lib/collectd/accounting.pickle', 'rb')
        total_traffic = pickle.load(f)
        collectd.info("load successful")
    except:
        total_traffic = {}
        collectd.info("load failed")
        

    try:
        close (f)
    except:
        pass

    plugin = accounting()
    collectd.register_config(plugin.configure_callback)
    collectd.register_init(plugin.init_callback)
