# frozen_string_literal: true

class HealthCheck
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] == '/health_check'
      body = 'ok'
      status = 200
      header = { 'Content-Type' => 'text/plain' }
      Rack::Response.new(body, status, header).finish
    else
      @app.call(env)
    end
  end
end

# ab -n 10000 http://localhost:3000/health_check
