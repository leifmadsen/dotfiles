import json
import sys
from subprocess import Popen, DEVNULL

class ClickEventHandler(Thread):
    '''
    Handle Click events.
    '''
    def __init__(self, **kwargs):
        Thread.__init__(self, **kwargs)
        self.daemon = True
        self.calendar_name = 'gsimplecal'
        self.event_name = 'Date'
        self.calendar = None
        
    def run(self):
        for event in sys.stdin:
            if event.startswith('['):
                continue
            elif event.startswith(','):
                event = event.lstrip(',')
            
            name = json.loads(event)['name']
            
            if name == self.event_name:
                if self.calendar == None:
                    self.calendar = Popen(self.calendar_name, stdout=DEVNULL)
                else:
                    self.calendar.terminate()
                    self.calendar = None
            else:
                pass

