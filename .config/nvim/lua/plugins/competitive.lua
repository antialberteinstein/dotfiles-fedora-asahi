-- Competitive programming with competitest.nvim: compile, run against test
-- cases and compare output. Problems can be received straight from the
-- browser with the Competitive Companion extension (port 27121).
return {
  {
    "xeluxee/competitest.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CompetiTest",
    keys = {
      { "<leader>pr", "<Cmd>CompetiTest run<CR>", desc = "Run test cases" },
      { "<leader>pa", "<Cmd>CompetiTest add_testcase<CR>", desc = "Add test case" },
      { "<leader>pe", "<Cmd>CompetiTest edit_testcase<CR>", desc = "Edit test case" },
      { "<leader>pd", "<Cmd>CompetiTest delete_testcase<CR>", desc = "Delete test case" },
      { "<leader>pu", "<Cmd>CompetiTest show_ui<CR>", desc = "Show results" },
      { "<leader>pp", "<Cmd>CompetiTest receive problem<CR>", desc = "Receive problem" },
      { "<leader>pc", "<Cmd>CompetiTest receive contest<CR>", desc = "Receive contest" },
    },
    opts = {
      compile_command = {
        c = { exec = "gcc", args = { "-std=c17", "-O2", "-Wall", "$(FNAME)", "-o", "$(FNOEXT)" } },
        cpp = { exec = "g++", args = { "-std=c++17", "-O2", "-Wall", "-Wextra", "$(FNAME)", "-o", "$(FNOEXT)" } },
      },
      run_command = {
        c = { exec = "./$(FNOEXT)" },
        cpp = { exec = "./$(FNOEXT)" },
        python = { exec = "python3", args = { "$(FNAME)" } },
      },
      received_files_extension = "cpp",
    },
  },
}
