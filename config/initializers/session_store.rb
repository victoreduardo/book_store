# frozen_string_literal: true

# Session cookie options. HttpOnly blocks JavaScript from reading the cookie
# (Rails default: true — correct for production).
#
# For the XSS lab in development only, HttpOnly is disabled so payloads using
# document.cookie can demonstrate exfiltration. Never disable HttpOnly in production.

Rails.application.config.session_store :cookie_store,
  key: "_book_store_session",
  httponly: !Rails.env.development?
