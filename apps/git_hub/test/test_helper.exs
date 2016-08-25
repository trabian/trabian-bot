ExUnit.start()

[:bypass, :logger, :httpoison]
|> Enum.each(&Application.ensure_all_started/1)
