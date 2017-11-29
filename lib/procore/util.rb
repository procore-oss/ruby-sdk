module Procore
  # Collection of utility methods used within the gem.
  module Util
    def self.log_info(message, meta = {})
      return if Procore.configuration.logger.nil?

      meta_string = meta.map do |key, value|
        "#{colorize(key, :cyan)}: #{colorize(value, :cyan, bold: true)};"
      end.join(" ")

      Procore.configuration.logger.info(
        "#{colorize('Procore', :yellow)} <<- " \
        "#{colorize(message.ljust(22), :cyan)} <<- #{meta_string}",
      )
    end

    def self.log_error(message, meta = {})
      return if Procore.configuration.logger.nil?

      meta_string = meta.map do |key, value|
        "#{colorize(key, :red)}: #{colorize(value, :red, bold: true)};"
      end.join(" ")

      Procore.configuration.logger.info(
        "#{colorize('Procore', :red)} <<- " \
        "#{colorize(message.ljust(22), :red)} <<- #{meta_string}",
      )
    end

    def self.colorize(text, color, bold: false)
      mode = bold ? 1 : 0
      foreground = 30 + COLOR_CODES.fetch(color)
      background = 40 + COLOR_CODES.fetch(:default)

      "\033[#{mode};#{foreground};#{background}m#{text}\033[0m"
    end
    private_class_method :colorize

    COLOR_CODES = {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7,
      default: 9,
    }.freeze
    private_constant :COLOR_CODES
  end
end
