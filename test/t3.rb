
require 'Nexp'
require 'Bento'
require 'byebug'

nexp = <<END
(numbers
	(first 1)
	(second 2)
	(third 3))
(words
	mary had a little lamb
	)
(nodes
	:name letters
	(node a 1)
	(node b 2)
	(node c 3))
END

ne = Nexp::Nexp.from_string(nexp)
puts ne.find(:nodes).text

