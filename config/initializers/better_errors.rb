if defined? BetterErrors
  # https://github.com/charliesome/better_errors/issues/270
  BetterErrors::Middleware.allow_ip! '0.0.0.0/0'
end
