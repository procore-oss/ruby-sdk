require "test_helper"

class Procore::UtilTest < Minitest::Test
  def setup
    @output = StringIO.new
    Procore.configuration.logger = Logger.new(@output)
  end

  def test_log_info
    Procore::Util.log_info("Hello")
    assert_match /Hello/, @output.string
  end
end
