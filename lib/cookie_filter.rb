class CookieFilter
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    params = env["action_dispatch.request.parameters"]
    if params && params["subdomain"] && params["subdomain"] == "api"
      headers.delete 'Set-Cookie'
    end
    [status, headers, body]
  end
end