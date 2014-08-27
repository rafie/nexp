
require 'minitest/autorun'
require 'Nexp'

# this is not actually a Nexp test but rather an experiment of the nexp semantics
# using plain nested array.

#----------------------------------------------------------------------------------------------

module Functions
	def car(x)
		x[0]
	end
	
	def cdr(x)
		x.drop(1)
	end

	def atom?(x)
		!list?(x)
	end
	
	def list?(x)
		x.is_a? Enumerable
	end

	def value(x)
		if atom?(x)
			x
		elsif x == []
			nil
		else
			value(car(x))
		end
	end
	
	def find(x, y)
		if atom?(x)
			if x.to_s == y.to_s
				[]
			else
				nil
			end
		elsif x == []
			nil
		else
			z = value(x)
#			if z == nil || z.to_s != y.to_s
			if z.to_s != y.to_s
				find(cdr(x), y)
			else
				if atom?(car(x))
					if car(x).is_a? Symbol
						car(cdr(x))
					else
						[]
					end
				else
					cdr(car(x))
				end
			end
		end
	end
end

#----------------------------------------------------------------------------------------------

class Test1 < Minitest::Test

	include Functions

	def setup
		@x = 
		  ['numbers',
		    'first',
		    ['second', 2],
		    ['third', :a, :b, :c],
		    :forth, 4,
		    ['fifth']]
	end

	def test_1
		assert_equal [], find(['a', 'b', 'c'], 'a')
	end
	
	def test_first
		assert_equal [], find(@x, :first)
	end

	def test_second
		assert_equal [2], find(@x, :second)
	end

	def test_third
		assert_equal [:a, :b, :c] , find(@x, :third)
	end

	def test_forth
		assert_equal 4, find(@x, :forth)
	end

	def test_fifth
		assert_equal [], find(@x, :fifth)
	end

	def test_sixth
		assert_equal nil, find(@x, :sixth)
	end
end

#----------------------------------------------------------------------------------------------

class Test2 < Minitest::Test

	include Functions

	def setup
		@x = 
		  [
		    ['numbers',
		      'first',
		      ['second', 2],
		      ['third', :a, :b, :c],
		      :forth, 4,
		      ['fifth']],
		    ['words', 'car', 'bus', 'train']
		  ]
	end

	def test_numbers
		assert_equal [:a, :b, :c], find(find(@x, :numbers), :third)
	end

	def test_words
		assert_equal ['car', 'bus', 'train'], find(@x, :words)
	end

	def test_empty_str
		assert_equal nil, find(@x, '')
	end
end

#----------------------------------------------------------------------------------------------

class Test3 < Minitest::Test

	include Functions

	def setup
		@x = 
		  [
		    [ [ [] ], 17 ],
		    ['a', 1],
		    [],
		    :b, 2,
		    []
		  ]
	end

	def test_a
		assert_equal [1], find(@x, :a)
	end

	def test_b
		assert_equal 2, find(@x, :b)
	end

	def test_empty_str
		assert_equal [17], find(@x, '')
	end
end

#----------------------------------------------------------------------------------------------
