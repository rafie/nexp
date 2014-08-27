
require 'Nexp'
require 'Bento'
# require 'byebug'

ne = Nexp.from_file("lots.ne")
lots = ne[0][:lots]
x = lots/:lot
y = x%"nbu.mcu"
pp ~ne
z = 1
