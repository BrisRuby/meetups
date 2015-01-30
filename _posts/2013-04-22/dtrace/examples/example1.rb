class CustomException < Exception; end

def method1(str)
  puts "String: #{str}"
  if str=="custom"
    raise CustomException
  else
    raise str
  end
end

loop do
  begin
    print "(Process #{$$}): Press enter to raise exception: "
    line = gets
    method1(line.chomp)
  rescue Interrupt
    puts "\nBye."
    break
  rescue Exception => ex
    puts "Exception: #{ex.inspect}"
  end
end

