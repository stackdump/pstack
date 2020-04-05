from shovel.adapter import logstash
from shovel import listener

print("start logstash shovel tcp://0.0.0.0:8040")
listener.event_loop(logstash.push_to_logstash)
