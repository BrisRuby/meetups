require 'ffi'


module MattCustom
  LIB_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'custom.so'))
  puts "lib path: #{LIB_PATH}"
  
  extend FFI::Library
  
  begin
    # load library with FFI
    ffi_lib LIB_PATH
    
    # create methods
    attach_function :matt_custom_action_begin, [:string], :int
    attach_function :matt_custom_action_end, [], :int
  rescue LoadError
    puts "failed to load library"
    
    # create empty stub methods
    def matt_custom_action_begin(label); end
    def matt_custom_action_end; end
    module_function :matt_custom_action_begin
    module_function :matt_custom_action_end
  end
  
  
  # trace interface
  def trace(label, &block)
    MattCustom.matt_custom_action_begin(label)
    yield
  ensure
    MattCustom.matt_custom_action_end()
  end
  
  module_function :trace
end

puts "hello"
puts MattCustom.matt_custom_action_begin("there")
