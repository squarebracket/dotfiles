import json
import sys

j = sys.stdin.read()
print j
obj = json.loads(j)
program_to_filter = int(sys.argv[1])

print program_to_filter

programs = obj[u'programs']

class Stream(object):

    def __init__(self, codec_type, codec_name, codec_long_name, codec_time_base,
                 hearing_impaired, language=None):
        self.codec_type = codec_type
        self.code_name = codec_name
        self.codec_long_name = codec_long_name
        self.codec_time_base = codec_time_base
        self.hearing_impaired = hearing_impaired
        self.language = language

class AudioStream(Stream):

    def __init__(self, codec_type, codec_name, codec_long_name, codec_time_base,
                 hearing_impaired, language, channels, channel_layout, sample_rate,
                 bit_rate):
        super(self.__class__, self).__init__(codec_type, codec_name,
                                             codec_long_name, codec_time_base,
                                             hearing_impaired, language)
        self.channels = channels
        self.channel_layout = channel_layout
        self.sample_rate = sample_rate
        self.bit_rate = bit_rate

class VideoStream(Stream):

    def __init__(self, codec_type, codec_name, codec_long_name, codec_time_base,
                 hearing_impaired, language, width, height, sample_aspect_ratio,
                 display_aspect_ratio, pix_fmt, r_frame_rate, max_bit_rate):
        super(self.__class__, self).__init__(codec_type, codec_name,
                                             codec_long_name, codec_time_base,
                                             hearing_impaired, language)
        self.width = width
        self.height = height
        self.sample_aspect_ratio = sample_aspect_ratio
        self.display_aspect_ratio = display_aspect_ratio
        self.pix_fmt = pix_fmt
        self.r_frame_rate = r_frame_rate
        self.max_bit_rate = max_bit_rate

class Program(object):

    def __init__(self, j):
        self.progam_num = j['program_num']
        self.pmt_pid = j['pmt_pid']
        self.pcr_pid = j['pcr_pid']
        self.service_name = j['tags']['service_name']
        self.streams = []
        for stream in j['streams']:
            if stream['codec_type'] == 'audio':
                self.streams.append(AudioStream(
                    stream['codec_type'],
                    stream['codec_name'],
                    stream['codec_long_name'],
                    stream['codec_time_base'],
                    stream['disposition']['hearing_impaired'],
                    stream['tags']['language'],
                    stream['channels'],
                    stream['channel_layout'],
                    stream['sample_rate'],
                    stream['bit_rate']))
            elif stream['codec_type'] == 'video':
                self.streams.append(VideoStream(
                    stream['codec_type'],
                    stream['codec_name'],
                    stream['codec_long_name'],
                    stream['codec_time_base'],
                    stream['disposition']['hearing_impaired'],
                    stream['tags']['language'],
                    stream['width'],
                    stream['height'],
                    stream['sample_aspect_ratio'],
                    stream['display_aspect_ratio'],
                    stream['pix_fmt'],
                    stream['r_frame_rate'],
                    stream['max_bit_rate']))






for program in programs:
    if program['program_num'] == program_to_filter:
        program = Program(program)
        # print program

