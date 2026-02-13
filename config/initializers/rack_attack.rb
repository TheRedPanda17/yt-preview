class Rack::Attack
  # Throttle login attempts by IP - 5 attempts per 60 seconds
  throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/admin/login" && req.post?
  end

  # Throttle signup attempts by IP - 3 attempts per 60 seconds
  throttle("signups/ip", limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == "/admin/signup" && req.post?
  end

  # Throttle vote submissions by IP - 20 votes per 60 seconds
  throttle("votes/ip", limit: 20, period: 60.seconds) do |req|
    req.ip if req.path.include?("/vote_") && req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |req|
    [429, { "Content-Type" => "text/html" }, ["Too many requests. Please wait a moment and try again."]]
  end
end
