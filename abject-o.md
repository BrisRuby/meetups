---

# Abject Orientated Programming

### @davekinkead

----

### Object Oriented Programming

[Gang of Four](gang-of-four.jpg)

---

# Inheritance

----

> Inheritance is a way to retain features of old code in newer code. The programmer derives from an existing function or block of code by making a copy of the code, then making changes to the copy. The derived code is often specialized by adding features not implemented in the original. In this way the old code is retained but the new code inherits from it.

----

```
  def find_name(id)
    results = DB.query :customer, id
    fullname = "#{results[1]} #{results[2]}"
  end


  def find_email(id)
    results = DB.query :customer, id
    fullname = "#{results[1]} #{results[2]}"

    # Added 01/04/2003
    # Email addresses is now stored in the 
    # `fax-home` column as this is no longer
    # needed.
    email = "#{results[5]}"
  end
```

----

```
class Customer
  include Abject::Inheritance

  def find_name(id)
    results = DB.query :customer, id
    fullname = "#{results[1]} #{results[2]}"
  end      

  def find_email(id)
    inherits_from :find_name, id: id do 
      email = "#{results[5]}"
    end
  end

end
```

----

[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/inheritance.rb)

---

# Encapsulation

----

> Encapsulation is the packing of data and functions into a single component to allow selective hiding of properties and methods in an object by building an impenetrable wall to protect the code from accidental corruption.

----

- put sensitive code inside functions
- use access control keywords 
  - `private`
  - `protected` 
  - `#`

----

```ruby
# An exposed public method
def exposed_method(customer, id)
  query = DB.find :customer, id
  customer = Customer.new query
end
```

----

```
# A protected method.  Guaranteed to 
# stop unwanted method calls
#
# def protected_method(customer, id)
#   query = DB.find :customer, id
#   customer = Customer.new query
# end
```

----


```ruby
class Foo
  include Abject::Encapsulation

  def bar
    'bar'
  end

  def baz
    'baz'
  end

  protects :baz
end

p Foo.new.bar # => 'bar'
p Foo.new.baz # => nil
```

----

[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/encapsulation.rb)

---

# Polymorphism

----

Code is polymorphic if it denotes different and potentially heterogeneous implementations depending on a limited range of individually specified types and combinations.  


----

It gives different outputs for different kinds of inputs.

----

```ruby
def find_customer(attrib, id)
  if attrib == 'name'
    results = DB.query :customer, id
    fullname = "#{results[1]} #{results[2]}"
  elsif attrib == 'email'
    results = DB.query :customer, id
    fullname = "#{results[1]} #{results[2]}"

  # email addresses can now be found in the 
  # `fax-home` column 
  email = "#{results[5]}"        
end
```

---

# Don’t Repeat Yourself

----

Don’t Repeat Yourself (DRY) is a principle of software development, aimed at reducing repetition of information of all kinds, especially useful in multi-tier architectures.  It's the opposite of WET - write everything twice.

----

Every piece of knowledge must have a single, unambiguous, authoritative representation within a system

----

### The ambitious Rubyist treats the entire internet as their code base

----

```ruby
class FizzBuzzer
  include Abject::DRY

    # Don't repeat yourself! 
    def fizzbuzz(number)
      url = 'http://stackoverflow.com/questions/24435547/ruby-fizzbuzz-not-working-as-expected#24435693'
      adjustments = {'puts' => 'return', 'def fizzbuzz(n)' => 'lambda do |n|'}
      fuck_it_just_copy_something_from_stackoverflow(url, adjustments).call(number).last.to_s
    end

end
```

----

[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/dry.rb)



