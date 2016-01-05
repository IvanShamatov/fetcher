require File.expand_path '../test_helper.rb', __FILE__
HTTPI.log = false

class NPMTest < Minitest::Test
  
  def test_dependencies_for
    stub_request(:get, "http://registry.npmjs.org/forever/latest").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
      to_return(:status => 200, :headers => {}, 
        :body => '{"dependencies": {
                  "cliff": "~0.1.9",
                  "clone": "^1.0.2",
                  "colors": "~0.6.2",
                  "flatiron": "~0.4.2",
                  "forever-monitor": "~1.6.0",
                  "nconf": "~0.6.9",
                  "nssocket": "~0.5.1",
                  "object-assign": "^3.0.0",
                  "optimist": "~0.6.0",
                  "path-is-absolute": "~1.0.0",
                  "prettyjson": "^1.1.2",
                  "shush": "^1.0.0",
                  "timespan": "~2.3.0",
                  "utile": "~0.2.1",
                  "winston": "~0.8.1"
                  }}')
    forever = NPM.dependencies_for('forever')
    assert_equal forever, ["cliff", "clone", "colors", "flatiron", "forever-monitor", "nconf", "nssocket", "object-assign", "optimist", "path-is-absolute", "prettyjson", "shush", "timespan", "utile", "winston"] 
    
    stub_request(:get, "http://registry.npmjs.org/colors/latest").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
      to_return(:status => 200, :headers => {}, :body => "{}")
    colors = NPM.dependencies_for('colors')
    assert_equal colors, []
  end

  def test_all_dependencies_recursively_and_only_once
    stub_request(:get, "http://registry.npmjs.org/forever/latest").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
      to_return(:status => 200, :headers => {}, 
        :body => '{"dependencies": {
                  "cliff": "~0.1.9",
                  "clone": "^1.0.2",
                  "colors": "~0.6.2"}
                  }')
    stub_request(:get, "http://registry.npmjs.org/cliff/latest").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
        to_return(:status => 200, :headers => {}, 
          :body => '{"dependencies": {
                    "colors": "~0.1.9"}
                    }')
    stub_request(:get, "http://registry.npmjs.org/clone/latest").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
        to_return(:status => 200, :headers => {}, 
          :body => '{"dependencies": {
                    "winston": "~0.1.9", 
                    "colors": "~0.1.9"}
                    }')
    stub_request(:get, "http://registry.npmjs.org/winston/latest").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
        to_return(:status => 200, :headers => {}, :body => '{}')
    stub_request(:get, "http://registry.npmjs.org/colors/latest").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'HTTPClient/1.0 (2.6.0.1, ruby 2.1.1 (2014-02-24))'}).
        to_return(:status => 200, :headers => {}, :body => '{}')
    packet = NPM.new('forever')
    dependencies = packet.all_dependencies
    assert_equal dependencies - ['cliff', 'clone', 'colors', 'winston'], []
    assert_requested(:get, "http://registry.npmjs.org/colors/latest", times: 1)
  end

end