ExUnit.start

[:bypass, :git_hub]
|> Enum.map(&Application.ensure_all_started/1)
