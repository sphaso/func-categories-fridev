FROM elixir:1.6.4

RUN groupadd -g 1000 app

RUN useradd -g 1000 -u 1000 --system --create-home app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex.info

RUN cp -rp /root/.mix /home/app/
RUN chown -R app:app /home/app/.mix

USER app
