import subprocess
import os

from powerline.segments import Segment

HOMEDIR = os.environ['HOME']
DOTFILES = os.environ['DOTFILES']
VAN_HUD_FILE = os.path.join(HOMEDIR, DOTFILES, 'shared-shell-scripts', 'vantrix', 'van-hud')

def van_hud(command):
    p = subprocess.Popen(['bash', VAN_HUD_FILE, command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    out = out.strip()
    if out == '':
        return None
    else:
        return out

class VantrixServices(Segment):
    
    def __call__(self, pl):
        output = subprocess.Popen(['~/.van_services.sh',], stdout=subprocess.PIPE).communicate()
        return output

def puppet_running(pl):
    if os.path.isfile('/var/lib/puppet/state/agent_catalog_run.lock'):
        return "Applying puppet"

def van_active_services(pl):
    return van_hud('--active-services')

def van_failed_services(pl):
    return van_hud('--failed-services')

def van_mongo(pl):
    return van_hud('--mongo')

def van_gluster(pl):
    return van_hud('--gluster')
