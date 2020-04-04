import logging
import logstash
import sys

# FIXME: set to docker hostname or use ENV var
host = 'localhost'

_logger = logging.getLogger('python-logstash-logger')
_logger.setLevel(logging.INFO)
#_logger.addHandler(logstash.LogstashHandler(host, 5959, version=1))
_logger.addHandler(logstash.TCPLogstashHandler(host, 8345, version=1))

error = _logger.error
info = _logger.info
warning = _logger.warning

def test_log():
    #_logger.error('python-logstash: test logstash error message.')
    #_logger.info('python-logstash: test logstash info message.')
    #_logger.warning('python-logstash: test logstash warning message.')

    # add extra field to logstash message
    extra = {
        #'test_string': 'python version: ' + repr(sys.version_info),
        #'test_boolean': True,
        'test_dict': {'a': 1, 'b': 'c', 'd': [0, 1]},
        #'test_float': 1.23,
        #'test_integer': 123,
        #'test_list': [1, 2, '3'],
    }

    info('python-logstash: test extra fields', extra=extra)

if __name__ == '__main__':

    test_log()
