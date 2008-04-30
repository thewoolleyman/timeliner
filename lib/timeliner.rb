$timeliner_before = {}
$timeliner_after = {}
module Timeliner
  VERSION = '0.1.0'
  @@ordered_before_keys ||= []
  @@ordered_after_keys ||= []

  def self.setup_report(report_name)
    @@report_name = report_name
    clear
  end
  
  def self.clear
    @@ordered_before_keys = []
    @@ordered_after_keys = []
    $timeliner_before = {}
    $timeliner_after = {}
  end
  
  def self.elapsed(key)
    $timeliner_after[key] - $timeliner_before[key]
  end
  
  def self.elapsed_from_start(key)
    $timeliner_after[key] - @@start_timestamp
  end
  
  def self.time(key)
    unless defined?(@@report_name)
      setup_report("MyReport")
    end
    before(key)
    yield
    after(key)
  end
  
  def self.generate_report
    return [] unless ENV['TIMELINER']
    @@output = []
    output "-------- Timeliner Report #{@@report_name} ---------"
    output "Elapsed times (ordered):"
    all_elapsed = {}
    @@ordered_before_keys.each do |key|
      output "#{formatted_timestamp(elapsed(key))}: #{key}"
      all_elapsed[key] = elapsed(key)
    end
    
    output 
    output "Elapsed times (sorted):"
    all_elapsed_sorted = all_elapsed.sort_by {|key, value| all_elapsed[key]}
    all_elapsed_sorted.each do |key, value|
      output "#{formatted_timestamp(value)}: #{key}"
    end
    
    output
    output "Timeline:"
    first_before_key = @@ordered_before_keys.first
    output "0:     Start (before #{first_before_key})"
    @prior_elapsed_from_start = 0
    @total_accounted = 0
    @total_unaccounted = 0
    @@ordered_after_keys.each do |key|
      current_elapsed_from_start = elapsed_from_start(key)
      elapsed_since_last_key = current_elapsed_from_start - @prior_elapsed_from_start
      accounted = elapsed(key)
      @total_accounted += accounted
      unaccounted = elapsed_since_last_key - accounted
      @total_unaccounted += unaccounted
      output "#{formatted_timestamp(current_elapsed_from_start)}: (elapsed: +#{formatted_timestamp(elapsed_since_last_key)}) (accounted: +#{formatted_timestamp(accounted)}) (unaccounted: #{formatted_timestamp(unaccounted)}): #{key}"
      @prior_elapsed_from_start = current_elapsed_from_start
    end
    last_after_key = @@ordered_after_keys.last
    current_elapsed_from_start = elapsed_from_start(last_after_key)
    elapsed_since_last_key = current_elapsed_from_start - @prior_elapsed_from_start
    unaccounted = elapsed_since_last_key
    @total_unaccounted += unaccounted
    output "#{formatted_timestamp(current_elapsed_from_start)}: (elapsed: +#{formatted_timestamp(elapsed_since_last_key)}) End                (unaccounted: #{formatted_timestamp(unaccounted)}) (after #{last_after_key})"
    output "Total: #{formatted_timestamp(current_elapsed_from_start)}"
    output "Total Accounted: #{formatted_timestamp(@total_accounted)}"
    output "Total Unaccounted: #{formatted_timestamp(@total_unaccounted)}"
    output "----------------------------------"
    @@output
  end

  def self.print_report
    generate_report.each do |line|
      puts line
    end
  end

  def self.now_timestamp
    ("%10.5f" % Time.now.to_f).to_f
  end
  
  def self.formatted_timestamp(timestamp)
    "%0.2f" % timestamp
  end
  
  def self.output(line = '')
    @@output << line
  end
  
  private
  # 'before' and 'after' methods are private to prevent the possibility of overlapping times, 
  # everything should be done via 'time'
  def self.before(key)
    ts = now_timestamp
    @@start_timestamp = ts if @@ordered_before_keys.size == 0
    @@ordered_before_keys << key
    $timeliner_before[key] = ts
  end
  
  def self.after(key)
    @@ordered_after_keys << key
    $timeliner_after[key] =  now_timestamp
  end  
end