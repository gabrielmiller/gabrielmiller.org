import Config

config :tableau, :reloader,
  patterns: [
    ~r"^lib/.*.ex",
    ~r"^(_posts|_pages)/.*.md",~r"^extra/.*.(css|js)",
    ~r"^assets/.*.(css|js)"
  ]

config :web_dev_utils, :reload_log, true
# uncomment this if you use something like ngrok
# config :web_dev_utils, :reload_url, "'wss://' + location.host + '/ws'"

config :tailwind,
  version: "4.1.12",
  default: [
    args: ~w(
    --input=./site.css
    --output=../../_site/css/site.css
    ),
    cd: Path.expand("../assets/css", __DIR__)
    # Intentionally scoped so tailwind doesn't include classes except from whitelisted filepaths references in css
  ]

config :tableau, :assets,
  tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}

config :tableau, :config,
  include_dir: "static",
  url: "http://localhost:4999",
  markdown: [
    mdex: [
      extension: [
        table: true,
        header_ids: "",
        tasklist: true,
        strikethrough: true,
        autolink: true,
        alerts: true,
        footnotes: true
      ],
      render: [unsafe: true],
      syntax_highlight: [formatter: {:html_inline, theme: "neovim_dark"}]
    ]
  ]

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true
config :tableau, Tableau.DataExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: false,
  title: "Gabriel Miller",
  description: "My abode on the internet"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
