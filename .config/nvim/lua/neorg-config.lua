require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/notes",
                },
            },
        },
        ["core.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
    },
})

