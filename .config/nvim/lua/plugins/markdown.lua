return {
  -- LazyVim's markdown extra disables checkbox rendering; re-enable it so
  -- `- [ ]` / `- [x]` render as real tasks.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        enabled = true,
      },
    },
  },
}
