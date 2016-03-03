import subprocess
import os

from powerline.segments import Segment

DOTFILES = os.environ['DOTFILES']
VAN_HUD_FILE = os.path.join('~', DOTFILES, 'shared-shell-scripts', 'vantrix', 'van-hud')

class VantrixServices(Segment):
    
    def __call__(self, pl):
        output = subprocess.Popen(['~/.van_services.sh',], stdout=subprocess.PIPE).communicate()
        return output

def puppet_running(pl):
    if os.path.isfile('/var/lib/puppet/state/agent_catalog_run.lock'):
        return "Applying puppet"

def van_active_services(pl):
    p = subprocess.Popen(['bash', VAN_HUD_FILE, '--failed-services'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    return out

def van_failed_services(pl):
    p = subprocess.Popen(['bash', VAN_HUD_FILE, '--failed-services'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    return out

