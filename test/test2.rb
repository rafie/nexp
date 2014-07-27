
require 'minitest/autorun'
require 'Nexp'

# this is not actually a Nexp test but rather an experiment of the nexp semantics
# using plain nested array.

class Test1 < Minitest::Test

	def setup
		@x = 
			[#:numbers,
			  'first',
			  [:second, 2],
			  [:third, :a, :b, :c],
			  :forth, 4,
			  [:fifth]]
	end

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
			if x == y
				[]
			else
				nil
			end
		elsif x == []
			nil
		else
			z = value(x)
			if z == [] || z != y
				find(cdr(x), y)
			else
				if atom?(car(x))
					if car(x).is_a? Symbol
						raise "forth"
					else
						cdr(x)
					end
				else
					cdr(car(x))
				end
			end
		end
	end
	
	def test_first
		assert_equal [[:second, 2], [:third, :a, :b, :c], :forth, 4, [:fifth]], find(@x, :first)
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

