module Markets
  class IngestJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      PredictitRobot.new.ingest_markets
    end
  end
end
