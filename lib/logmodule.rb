require 'logger'
require 'fileutils'

module LoggerModule
  def get_logger(name, shift_age, shift_size, level)
    # create the directory for the log if it doesn't exist
    if !File.exist? File.dirname(name) then
      FileUtils.mkdir_p File.dirname(name)
    end
          
    # create the logger and give it back
    log = Logger.new(name, shift_age, shift_size)
    log.level = level
    log
  end
end
