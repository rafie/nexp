
require "minitest/autorun"
require 'Nexp'
require 'byebug'

#----------------------------------------------------------------------------------------------

class Test1 < Minitest::Test

	@@nexp = <<END
(numbers
	(first 1)
	(second 2)
	(third 3))
(words
	mary had a little lamb)
(nodes
	:name letters
	(node a 1)
	(node b 2)
	(node c 3))
END

	def setup
		@ne = Nexp::Nexp.from_string(@@nexp)
		a = ~@ne[:numbers]
		z=1
	end
	
	def test_find_atom
		# (a b c)[:a] yields (b c)
		assert_equal @ne[:numbers][:first].to_i, 1
	end
	
	def test_find_list
		# ((a 1 2) b c)[:a] yields (1 2)
		assert_equal @ne[:words][:little].to_s, "lamb"
	end

	def test_index
		assert_equal 2, @ne[:numbers][1][1].to_i, 2
	end

	def test_node_op
		assert_equal ~@ne[:numbers], [["first", "1"], ["second", "2"], ["third", "3"]]
	end

	def test_cxr
		assert_equal 1, @ne.cxr(:adada).to_i
	end

	def test_enum
		y = []
		numbers = @ne[:numbers].each do |x|
			y << x.cadr.to_i
		end
		assert_equal [1, 2, 3], y
	end

	def test_enum_with_filter
		y = []
		numbers = @ne[:numbers].each(:first) do |x|
			y << x.cadr.to_i
		end
		assert_equal [1] , y
	end

	def test_cut
		assert_equal [["node", "a", "1"], ["node", "b", "2"], ["node", "c", "3"]], ~(@ne[:nodes]/:node)
	end
	
	def test_sel1
		assert_equal %w(2), ~((@ne[:nodes]/:node)%:b)
	end

	def test_rank1
		assert_equal %w(first second third), @ne[:numbers].rank0
	end

	def test_rank2
		assert_equal %w(a b c), (@ne[:nodes]/:node).rank1
	end
end

#----------------------------------------------------------------------------------------------

class Test2 < Minitest::Test
	@@nexp = <<END
(numbers
	:first 1
	:second 2 2a
	:third 3
	(:more 4 5 6))
END

	def setup
		@ne = Nexp::Nexp.from_string(@@nexp, :single)
	end

	def test_numbers
		assert_equal @ne[:numbers][:first].to_i, 1
		assert_equal @ne[:numbers][:second].to_i, 2
		assert_equal ~@ne[:numbers][:more], ["4", "5", "6"]
	end
end

#----------------------------------------------------------------------------------------------

class Test3 < Minitest::Test
	@@nexp = <<END
(numbers
	first
	(second 2)
	(third a b c)
	:forth 4
	(fifth))
END

	# test if it is possible to ommit brackets around 'first'
	def setup
		@ne = Nexp::Nexp.from_string(@@nexp, :single)
	end

	def test_first
		assert_equal [["second", "2"], ["third", "a", "b", "c"], ":forth", "4", ["fifth"]], ~@ne[:numbers][:first]
	end

	def test_second
		assert_equal '2', ~@ne[:numbers][:second]
	end

	def test_third
		assert_equal ['a', 'b', 'c'] , ~@ne[:numbers][:third]
	end

	def test_forth
		assert_equal "4", ~@ne[:numbers][:forth]
	end

	def test_fifth
		assert_equal [], ~@ne[:numbers][:fifth]
	end

	def test_sixth
		assert_equal nil, @ne[:numbers][:sixth]
	end

	def test_map_car
		skip "broken"
		assert_equal %w(first second third forth fifth), @ne[:numbers].map { |x| ~x.car }
	end
end

#----------------------------------------------------------------------------------------------

class Test4 < Minitest::Test

	@@nexp = <<END
(numbers
	(first 1)
	(second 2)
	(third 3))
(words
	mary had a little lamb)
(nodes
	:name letters
	(node a 1)
	(node b 2)
	(node c 3))
END

	@@nexp_single = <<END
(single
	(numbers
		(first 1)
		(second 2)
		(third 3)
		)
	(words
		mary had a little lamb)
	(nodes
		:name letters
		(node a 1)
		(node b 2)
		(node c 3)))
END


	@@nodes_out = <<END
(nodes
	:name letters
	(node a 1)
	(node b 2)
	(node c 3))
END

	@@nodes_in = <<END
:name letters
(node a 1)
(node b 2)
(node c 3)
END

	def setup
		@ne = Nexp::Nexp.from_string(@@nexp)
		@ne1 = Nexp::Nexp.from_string(@@nexp_single, :single)
	end

	def test_print_all
		assert_equal @@nexp.strip, @ne.text
	end

	def test_print_all_single
		assert_equal @@nexp_single.strip, @ne1.text
	end
	
	def test_print_nodes_out
		assert_equal @@nodes_out.strip, @ne.find(:nodes).text
	end

	def test_print_nodes_in
		assert_equal @@nodes_in.strip, @ne[:nodes].text(:free)
	end
end
