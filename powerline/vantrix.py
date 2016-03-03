import subprocess
import os

from powerline.segments import Segment

class VantrixServices(Segment):
    
    def __call__(self, pl):
        output = subprocess.Popen(['~/.van_services.sh',], stdout=subprocess.PIPE).communicate()
        return output

def puppet_running(pl):
    if os.path.isfile('/var/lib/puppet/state/agent_catalog_run.lock'):
        return "Applying puppet"

def van_services(pl):
    p = subprocess.Popen(['bash', '/root/.van_services.sh'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()

    return out
