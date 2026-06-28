require('scrollbar').setup({
  marks = {
    GitAdd = { color = 'LightGreen' },
    GitChange = { color = 'LightBlue' },
    GitDelete = { color = 'Orange' }
  },
  handlers = {
    gitsigns = true
  }
})
