
require 'Nexp'
require 'Bento'
require 'byebug'

ne = Nexp.from_file("lots.ne")
lots = ne[0][:lots]
x = lots/:lot
y = x%"nbu.mcu"
byebug
a = ne.cadr
z = 1
