class B
  def initialize(name)
    @name = name
  end

  def start
    puts "#{@name}-start"
  end

  def stop
    puts "#{@name}-stop"
  end
end

class A
  def initialize( names )
    @data = {}
    names.map{|x| @data[x] = B.new(x) }
  end

  def method_missing(name , lang = nil)
    @data[name.to_s]
  end

  def m1
    puts "m1"
  end
end

class C
  def initialize( *args )
    @data = {}
    args.map{|x| @data[x] = B.new(x) }
  end

  def method_missing(name , lang = nil)
    @data[name]
  end
end
a=A.new( ["category" , "repo"] )
puts a.category.start
puts a.repo.stop

c=C.new( :category , :repo )
puts c.category.start
puts c.repo.stop
