vim.g.mapleader = "\\"

local keymap = vim.keymap -- for conciseness

-- general keymaps

-- map j k to ESC
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- map \nh to switch off search highlighting
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Keep the system clipboard available for pasting while retaining removed text
-- in a dedicated Neovim register.
keymap.set({ "n", "x" }, "d", '"dd', { desc = "Delete into register d" })
keymap.set({ "n", "x" }, "c", '"dc', { desc = "Change into register d" })
keymap.set({ "n", "x" }, "x", '"dx', { desc = "Delete character into register d" })
keymap.set({ "n", "x" }, "s", '"ds', { desc = "Substitute into register d" })

-- Copy a Visual selection explicitly without deleting it.
keymap.set("x", "<D-c>", '"+y', { desc = "Copy selection to system clipboard" })

-- \+ to increment number; \- to decrement number
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window splitting and management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>S", "<cmd>%s/\\s\\+$//<CR>:let @/=''<CR>", { desc = "Delete trailing whitespaces" }) -- trim all whitespaces away

keymap.set("n", "<leader>s", "<cmd>set nolist!<CR>", { desc = "Show white space" })

-- Plugin keymaps
-- trouble
--vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
--vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
--vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
--vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
--vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
--vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true })
