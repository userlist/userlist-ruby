RSpec.configure do |config|
  config.before { Userlist.reset! }
end
