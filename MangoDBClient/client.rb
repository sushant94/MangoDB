require 'irb'
require File.expand_path "../db.rb", __FILE__

IRB.setup nil
IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context

IRB.conf[:PROMPT][:MANGO] = {
  :PROMPT_I => "MangoDB > ",  
  :PROMPT_S => "MangoDB \">", 
  :PROMPT_C => "MangoDB *>",  
  :RETURN => "%s\n"
}

IRB.conf[:PROMPT_MODE] = :MANGO
require 'irb/ext/multi-irb'
binding = binding()
IRB.irb nil, binding

