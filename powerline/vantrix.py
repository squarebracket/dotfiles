import subprocess
import re
import os

from powerline.segments import Segment

HOMEDIR = os.environ['HOME']
DOTFILES = os.environ['DOTFILES']
VAN_HUD_FILE = os.path.join(HOMEDIR, DOTFILES, 'shared-shell-scripts', 'vantrix', 'van-hud')

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
        mongo_state = van_hud('--mongo') 
        if mongo_state == 'Primary': 
            highlight = 'van_active_services'
        elif mongo_state == 'Secondary': 
            highlight = 'branch_dirty'
        elif mongo_state == 'Standalone':
            highlight = 'warning:regular'
        else:
            return None
        return [{ 
            'contents': "%s %s" % (self._PREFIX, mongo_state),
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

class VantrixMachine(Segment):

    def __call__(self, pl):
        hostname = get_file_contents('/etc/hostname')
        m = re.match(r'(machine\d\d).*', hostname)
        if not m:
            return None
        machine = m.group(1)
        if not machine or not DEPLOYMENT:
            return None
        return [{
            'contents': machine,
            'highlight_groups': [DEPLOYMENT,],
        }]
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
location = VantrixLocation()

def puppet_running(pl):
    if os.path.isfile('/var/lib/puppet/state/agent_catalog_run.lock'):
        return "Applying puppet"

def van_active_services(pl):
    return van_hud('--active-services')

def van_failed_services(pl):
    return van_hud('--failed-services')

