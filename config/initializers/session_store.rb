# frozen_string_literal: true

Rails.application.config.session_store :cookie_store,
  key: "_book_store_session",
  httponly: !Rails.env.development?
