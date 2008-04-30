require 'spec'
require File.expand_path(File.dirname(__FILE__) + "/../lib/timeliner.rb")

class TimelinerExample
  def self.run
    Timeliner.time(:method1) do
      method1
    end
    
    Timeliner.time(:method2) do
      method2
    end
  end
  
  def self.method1
    sleep 0.2
  end
  
  def self.method2
    sleep 0.2
  end  
end

describe Timeliner do
  before do
    ENV['TIMELINER'] = 'on'
  end
  
  it "should timeline" do
    TimelinerExample.run
    output_lines = Timeliner.generate_report
    output = output_lines.join
    output.should match /Total:/
    p $0
  end
end