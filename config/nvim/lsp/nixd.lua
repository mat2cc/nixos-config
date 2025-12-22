return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  settings = {
    nixd = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
}
