shared_context "MaintenanceApi::Client", driver: :chrome do # needs to start server in the background
  before do
    WebMock.disable_net_connect!(allow_localhost: true)
    MaintenanceApi::Client.base_uri "http://localhost:#{Capybara.current_session.server.port}/api/maintenance"
  end
end
