import subprocess
import re
import os

from powerline.segments import Segment

HOMEDIR = os.environ['HOME']
DOTFILES = os.environ['DOTFILES']
VAN_HUD_FILE = os.path.join(HOMEDIR, DOTFILES, 'shared-shell-scripts', 'vantrix', 'van-hud')

def get_hostname():
    p = subprocess.Popen(['hostname', ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    out = out.strip()
    if out == '':
        return None
    else:
        return out

def get_file_contents(f):
    p = subprocess.Popen(['cat', f], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    out = out.strip()
    if out == '':
        return None
    else:
        return out

def van_hud(command):
    p = subprocess.Popen(['bash', VAN_HUD_FILE, command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    out = out.strip()
    if out == '':
        return None
    else:
        return out

class VantrixMongo(Segment): 
    _PREFIX = 'Mongo:'
    def __call__(self, pl): 
        mongo_conf = van_hud('--mongo')
        m = re.match(r'(Primary|Secondary|Standalone|Failure|Inactive)(?: \((\w*)\))?', mongo_conf)
        if m:
            mongo_state = m.group(1)
            mongo_replset = m.group(2)
        else:
            mongo_state = None
            mongo_replset = None
        if mongo_state == 'Primary' or (mongo_state == 'Standalone' and not mongo_replset): 
            highlight = 'van_active_services'
        elif mongo_state == 'Secondary': 
            highlight = 'branch_dirty'
        elif (mongo_state == 'Standalone' and mongo_replset) or mongo_state == 'Failure':
            highlight = 'warning:regular'
        else:
            return None
        return [{ 
            'contents': "%s %s" % (self._PREFIX, mongo_conf),
            'highlight_groups': [highlight,], 
        }] 

    @staticmethod
    def truncate(pl, amount, segment, *args):
        if amount > len(VantrixMongo._PREFIX):
            # truncate the state as well
            c = segment['contents']
            if 'Primary' in c:
                state = 'Pri'
            elif 'Secondary' in c:
                state = 'Sec'
            elif 'Standalone' in c:
                state = 'SA'
            return state
        else:
            # just truncate the prefix
            return segment['contents'].replace(VantrixMongo._PREFIX + ' ', '')

mongo = VantrixMongo()
mongo.truncate = VantrixMongo.truncate

class VantrixGluster(Segment):

    def __call__(self, pl):
        gluster = van_hud('--gluster')
        if not gluster:
            return None
        m = re.match(r'(gv\d) \((\d+)%\)', gluster)
        if not m:
            return None
        vol = m.group(1)
        free = int(m.group(2))
        if free >= 90:
            highlight = 'van_gluster:warning'
        elif free >= 98:
            highlight = 'van_gluster:danger'
        else:
            highlight = 'van_gluster:fine'
        return [{
            'contents': '/mnt/%s: %s%% used' % (vol, free),
            'highlight_groups': [highlight,],
        }]

    @staticmethod
    def truncate(pl, amount, segment, *args):
        m = re.match("/mnt/(.*): (\d+%) used", segment['contents'])
        return "%s:%s" % (m.group(1), m.group(2))

gluster = VantrixGluster()


DEPLOYMENT = get_file_contents('/opt/deployment')
class VantrixDeployment(Segment):

    def __call__(self, pl):
        if not DEPLOYMENT:
            return None
        return [{
            'contents': DEPLOYMENT,
            'highlight_groups': [DEPLOYMENT,],
        }]
deployment = VantrixDeployment()

MACHINE = get_file_contents('/opt/machine')
class VantrixMachine(Segment):

    def __call__(self, pl):
        if not MACHINE or not DEPLOYMENT:
            return None
        return [{
            'contents': MACHINE,
            'highlight_groups': [DEPLOYMENT,],
        }]

    @staticmethod
    def truncate(pl, amount, segment, *args):
        if segment['contents'][0:6] == 'machin':
            return "m%s" % segment['contents'][-2:]
machine = VantrixMachine()

class VantrixLocation(Segment):

    def __call__(self, pl):
        location = get_file_contents('/opt/location')
        if not location:
            return None
        return [{
            'contents': location,
            'highlight_groups': [DEPLOYMENT,],
        }]

    @staticmethod
    def truncate(pl, amount, segment, *args):
        m = re.match("(s\d[a|b]).symkloud0(\d)", segment['contents'])
        return "%s.k%s" % (m.group(1), m.group(2))
location = VantrixLocation()

class VanVersion(Segment):

    def __call__(self, pl):
        return get_file_contents('/etc/vantrix-release')

    @staticmethod
    def truncate(pl, amount, segment, *args):
        m = re.match("Vantrix OS release (.*)", segment['contents'])
        if amount < 5:
            return "VantOS release %s" % m.group(1)
        elif amount < 13:
            return "VantOS %s" % m.group(1)
        else:
            return m.group(1)
VanVersion.highlight_groups = ['van_version',]
van_version = VanVersion()

def puppet_running(pl):
    if os.path.isfile('/var/lib/puppet/state/agent_catalog_run.lock'):
        return "Applying puppet"

def van_active_services(pl):
    return van_hud('--active-services')

def van_failed_services(pl):
    return van_hud('--failed-services')

