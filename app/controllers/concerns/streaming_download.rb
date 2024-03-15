# frozen_string_literal: true

module StreamingDownload
  extend ActiveSupport::Concern

  include ActionController::Live

  included do
    def streaming_download(filename)
      filename = ERB::Util.url_encode(filename)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      response.headers['Content-Type'] = 'text/event-stream'
      # https://github.com/rack/rack/issues/1619#issuecomment-848460528
      response.headers['Last-Modified'] = Time.current.httpdate
      yield response.stream
    ensure
      response.stream.close
    end
  end

  # ActionController::Liveとdeviseのauthenticate_user!を同時に使うとエラーになる問題の対策
  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
