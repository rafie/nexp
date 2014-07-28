
require 'nexp'

text = <<END
(lot
	(names a b c) x y)
END

ne = Nexp::Nexp.from_string(text)
pp ~ne[:lot]
pp ~ne[:lot][:names]
pp ne[:lot][:names][:a].class
pp ne[:lot][:names][:b].class
