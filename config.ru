require ::File.expand_path('../app', __FILE__)

Ramaze.start root: __DIR__, started: true, mode: :live

run Ramaze
