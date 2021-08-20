local present, icons = pcall(require, "nvim-web-devicons")
if not present then
   return
end

icons.setup {
   override = {
      lock = {
         icon = "",
         color = "red",
         name = "lock",
      },
   },
}
