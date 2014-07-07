
require 'byebug'

#----------------------------------------------------------------------------------------------

class Node
	attr_reader :line

	def initialize(line)
		@line = line
	end
	
	def +@
		list?
	end
	
	def ~
		skel
	end
end

#----------------------------------------------------------------------------------------------

class Atom < Node
	def initialize(line, s)
		super(line)
		@text = s
	end

	def list?
		false
	end
	
	def atom?
		true
	end

	def to_s
		@text
	end
	
	def to_i
		@text.to_i
	end

	def to_f
		@text.to_f
	end

	def skel
		to_s
	end
	
	def value=(x)
		@text = x
	end

	def car
		self
	end

	def cdr
		Nodes.new(0, [])
	end
end

#----------------------------------------------------------------------------------------------

class Nodes < Node
	include Enumerable

	def initialize(line, list)
		super(line)
		@list = list
	end

	def get(x)
		@list.find(x)
	end
	
	def list?
		true
	end
	
	def atom?
		false
	end
	
	def <<(node)
		@list << node
	end
	
	def empty?
		@list.empty?
	end

	def to_s
		@list.empty? ? "" : @list[0].to_s
	end

	def skel
		@list.map { |node| node.skel }
	end

	def find(x)
		return @list[x] if x.is_a? Fixnum

		x = x.to_s
		i = @list.find_index {|y| y.to_s == x }
		return @list[i] if i != nil

		# let's try searching for :x
		x = ":#{x}"
		i = @list.find_index {|y| y.to_s == x }
		return nil if i == nil

		@list[i]
	end

	def node(x)
		return @list[x] if x.is_a? Fixnum

		x = x.to_s
		i = @list.find_index {|y| y.to_s == x }
		if i == nil
			# let's try searching for :x
			x = ":#{x}"
			i = @list.find_index {|y| y.to_s == x }
			return nil if i == nil

			if @list[i].atom?
				# (:a b c)[:a] yields b
				return @list[i+1]
			else
				# ((:a b c) x y)[:a] yields (b c)
				# fall through
			end
		end

		if @list[i].atom?
			# (a b c)[:a] yields (b c)
			cdr = @list.drop(i + 1)
		else
			# ((a 1 2) b c)[:a] yields (1 2)
			n = @list[i]
			cdr = n.list.drop(1)
		end
		return Nodes.new(n.line, []) if cdr.size == 0
		return cdr[0] if cdr.size == 1
		Nodes.new(cdr[0].line, cdr)
	end

	def [](x)
		node(x)
	end
	
	def []=(i, x)
		node(x).value = x
	end

	def list
		@list
	end

	def size
		list.size
	end

	def cxr(x, y = self)
		return y if x.empty?
		case x[-1]
			when 'a'
				return nil if y.size == 0
				y = y[0]
			when 'd'
				return nil if y.size == 1
				y = Nodes.new(y[1].line, y.list.drop(1))
			else
				raise "invalid cxr specification"
		end
		cxr(x[0...-1], y)
	end
	
	def car;    cxr :a;    end
	def cdr;    cxr :d;    end
	def caar;   cxr :aa;   end
	def cadr;   cxr :ad;   end
	def cdar;   cxr :da;   end
	def cddr;   cxr :dd;   end
	def caaar;  cxr :aaa;  end
	def caadr;  cxr :aad;  end
	def cadar;  cxr :ada;  end
	def caddr;  cxr :add;  end
	def cdaar;  cxr :daa;  end
	def cdadr;  cxr :dad;  end
	def cddar;  cxr :dda;  end
	def cdddr;  cxr :ddd;  end
	def caaaar; cxr :aaaa; end
	def caaadr; cxr :aaad; end
	def caadar; cxr :aada; end
	def caaddr; cxr :aadd; end
	def cadaar; cxr :adaa; end
	def cadadr; cxr :adad; end
	def caddar; cxr :adda; end
	def cadddr; cxr :addd; end
	def cdaaar; cxr :daaa; end
	def cdaadr; cxr :daad; end
	def cdadar; cxr :dada; end
	def cdaddr; cxr :dadd; end
	def cddaar; cxr :ddaa; end
	def cddadr; cxr :ddad; end
	def cdddar; cxr :ddda; end
	def cddddr; cxr :dddd; end

	def each(what = nil)
		if what == nil
			@list.each { |x| yield x }
		else
			what = what.to_s
			@list.each { |x| yield x if x.to_s == what }
		end
	end

	# filter nodes by 1st element
	# ((node 1) (node 2) (goat))/:node yields ((node 1) (node 2))
	def cut(what)
		y = []
		each(what) { |x| y << x }
		return nil if y == []
		Nodes.new(y[0].line, y)
	end
	
	def /(what)
		cut(what)
	end
	
	def sel0(what)
		node(what)
	end

	# selects nodes by 2nd element
	# ((node a foo) (node b bar))%:a yields (foo)
	# ((node a foo) (node a bar))%:a yields [(foo) (bar)]
	def sel1(what)
#		byebug
		what = what.to_s
		y = select {|x| ~x.cadr == what}
		return nil if y == []
		y = y.map {|x| x.drop(2)}
		return nil if y == []
		y = y[0]
#		if y[0].count == 1
			y = y[0]
			Nodes.new(y.line, [y])
#		else
#			y.map{|x| Nodes.new(x[0].line, x)}
#		end
	end
	
	def %(what)
		sel1(what)
	end

	# ((a 1) (b 2) (c 3)) yields [a b c]
	def rank0
		map { |x| ~x.car }
	end

	# ((node a) (node b) (node c)) yields [a b c]
	def rank1
		map { |x| ~x.cadr }
	end
end

#----------------------------------------------------------------------------------------------

class Nexp < Nodes
	def initialize(stream, *opt, filename: '')
		@stream = Stream.new(stream)
		single = opt.include? :single
		@line = 0
		@list = single ? read.list[0].list : read.list
	end

	def Nexp.from_string(text, *opt)
		Nexp.new(StringIO.new(text), *opt)
	end
	
	def Nexp.from_file(fname, *opt)
		Nexp.new(File.open(fname, "r"), *opt, filename: fname)
	end

	def read(root = true)
		nodes_list = []
		start_line = @line
		token = ""
		state = :sep
		loop do
			c = @stream.read
			read_ch = false
			while !read_ch do
				case state
					when :sep
						if @stream.atEnd?
							state = :end
						else
							case c
								when ")"
									state = :end
								when "("
									state = :list
								when "\n"
									read_ch = true
									state = :newline
								else
									if Nexp.atom?(c)
										# token = c
										state = :atom
									else
										read_ch = true
									end
							end
						end

					when :newline
						++@line
						if c == "#"
							read_ch = true
							state = :comment
						else
							state = :sep
						end

					when :comment
						read_ch = true
						state = :newline if c == "\n"

					when :atom
						if @stream.atEnd? || Nexp.sep?(c)
							nodes_list << Atom.new(@line, token)
							token = ""
							state = :sep
						else
							c = @stream.read if Nexp.esc?(c)
							token << c
							read_ch = true
						end

					when :list
						nodes = read(false)
						if !nodes.empty?
							nodes_list << nodes
							read_ch = true
							state = :sep
						else
							state = :end
						end

					when :end
						raise "expected ) at end of file" if !root && c != ")"
						return Nodes.new(start_line, nodes_list)

					else
						raise "invalid state"
				end
			end
		end
	end

	def Nexp.atom?(c)
		c > ' '
	end

	def Nexp.esc?(c)
		c == "\\"
	end

	def Nexp.sep?(c)
		c <= " " || c == "(" || c == ")"
	end

	#------------------------------------------------------------------------------------------

	class Stream
		attr_reader :line, :col
		
		def initialize(stream)
			@stream = stream
			@line = 0
			@col = 0
			@newline = false
		end

		def read
			++@col
			c = @stream.getc
			if @newline
				@col = 0
				++@line
				while c == "#"
					@stream.fgets
					c = @stream.getc
				end
			end
			@newline = c == '\n'
			return c
		end
	
		def atEnd?
			@stream.eof?
		end
		
		def >>(x)
			x = read
		end
	end
end

#----------------------------------------------------------------------------------------------
