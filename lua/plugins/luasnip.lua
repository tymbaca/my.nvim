local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function get_current_folder_name()
  local path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local parts = split(path, "/")
  return parts[#parts - 1]
end

return {
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp",
  config = function()
    local ls = require("luasnip")

    local snippet_from_nodes = ls.sn

    local s = ls.snippet
    local sn = ls.snippet_node
    local isn = ls.indent_snippet_node
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    local r = ls.restore_node
    local events = require("luasnip.util.events")
    local ai = require("luasnip.nodes.absolute_indexer")
    local extras = require("luasnip.extras")
    local l = extras.lambda
    local rep = extras.rep
    local p = extras.partial
    local m = extras.match
    local n = extras.nonempty
    local dl = extras.dynamic_lambda
    local fmt = require("luasnip.extras.fmt").fmt
    local fmta = require("luasnip.extras.fmt").fmta
    local conds = require("luasnip.extras.expand_conditions")
    local postfix = require("luasnip.extras.postfix").postfix
    local types = require("luasnip.util.types")
    local parse = require("luasnip.util.parser").parse_snippet
    local ms = ls.multi_snippet
    local k = require("luasnip.nodes.key_indexer").new_key

    ls.config.set_config {
      history = true
    }


    local ts_locals = require "nvim-treesitter.locals"
    local ts_utils = require "nvim-treesitter.ts_utils"

    local get_node_text = vim.treesitter.get_node_text

    -------------------------------------------------------------------------------
    --------------------------------- SNIPPETS ------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("*", {
      s("inst",
        fmta("instruction<cur>", {
          cur = i(0),
        })),
    })

    ------------------------------------ SQL --------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("sql", {
      s("ie",
        fmta("IF EXISTS<cur>", {
          cur = i(0),
        })),

      s("ine",
        fmta("IF NOT EXISTS<cur>", {
          cur = i(0),
        })),
    })


    ---------------------------------- Erlang -------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("erlang", {
      s("fun",
        fmta("fun(<args>) ->> <body> end<cur>", {
          args = i(1),
          body = i(2),
          cur = i(0),
        })),
    })

    ---------------------------------- Elixir -------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("elixir", {
      s("do",
        fmta("do\n\t<cur>\nend", {
          cur = i(0),
        })),
    })

    ------------------------------------ ZIG --------------------------------------
    -------------------------------------------------------------------------------
    ls.add_snippets("zig", {
      s("i", fmta([[const <name> = std.<pref><name_rep>;<cur>]], {
        name = i(1),
        name_rep = rep(1),
        pref = i(2),
        cur = i(0),
      })),
      s("std", fmta([[const std = @import("std");<cur>]], {
        cur = i(0),
      })),
      s("ip", fmta([[const print = std.debug.print;<cur>]], {
        cur = i(0),
      })),

      s("pc", fmta([[pub const <left> = <right>;<cur>]], {
        left = i(1),
        right = i(2),
        cur = i(0),
      })),
      s("c", fmta([[const <left> = <right>;<cur>]], {
        left = i(1),
        right = i(2),
        cur = i(0),
      })),
      s("v", fmta([[var <left> = <right>;<cur>]], {
        left = i(1),
        right = i(2),
        cur = i(0),
      })),
      s("s", fmta("const <name> = struct {\n\t<cur>\n};", {
        name = i(1),
        cur = i(0),
      })),
      s("al", fmta("allocator: std.mem.Allocator<cur>", {
        cur = i(0),
      })),
      s("l", fmta([[print("<log>\n", .{<args>});<cur>]], {
        log = i(1),
        args = i(2),
        cur = i(0),
      })),
      s("arena", fmta("var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);\ndefer arena.deinit();<cur>", {
        cur = i(0),
      })),
      s("fn", fmta("fn <name>(<args>) <ret> {\n\t<cur>\n}", {
        name = i(1),
        args = i(2),
        ret = i(3),
        cur = i(0),
      })),
      s("pfn", fmta("pub fn <name>(<args>) <ret> {\n\t<cur>\n}", {
        name = i(1),
        args = i(2),
        ret = i(3),
        cur = i(0),
      })),

      s("te", fmta("try testing.expectEqual(<expect>, <actual>);", {
        actual = i(1),
        expect = i(0),
      })),
      s("ter", fmta("try testing.expectError(<expect>, <actual>);", {
        actual = i(1),
        expect = i(0),
      })),
    })

    ------------------------------------- C ---------------------------------------
    -------------------------------------------------------------------------------
    ls.add_snippets("c", {
      s("for",
        fmta("for (int i = 0; i << <iter>; i++) {\n\t<cur>\n}", {
          iter = i(1),
          cur = i(0),
        })),
      s("case",
        fmta("case <arg>:\n\t<cur>\n\tbreak;", {
          arg = i(1),
          cur = i(0),
        })),
      s("typedef",
        fmta("typedef <type> <cur>;", {
          type = i(1),
          cur = i(0),
        })),
      s("ts",
        fmta("typedef struct <name_rep> {\n\t<cur>\n} <name>;", {
          name = i(1),
          name_rep = rep(1),
          cur = i(0),
        })),
      s("te",
        fmta("typedef enum <name_rep> {\n\t<cur>\n} <name>;", {
          name = i(1),
          name_rep = rep(1),
          cur = i(0),
        })),
      s("v",
        fmta("(Vector3){<inner>}<cur>", {
          inner = i(1),
          cur = i(0),
        })),
      s("vvv",
        fmta("(Vector3){.x = <x>, .y = <y>, .z = <z>}<cur>", {
          x = i(1),
          y = i(2),
          z = i(3),
          cur = i(0),
        })),
      s("ig",
        fmta("#ifndef <name>\n#define <name_rep>\n<cur>\n#endif", {
          name = i(1),
          name_rep = rep(1),
          cur = i(0),
        })),
    })

    ----------------------------------- OCAML -------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("ocaml", {
      s("[|",
        fmta("[| <cur> |", {
          cur = i(0)
        })),
      s("[",
        fmta("[ <cur> ", {
          cur = i(0)
        })),
    })

    ----------------------------------- YAML --------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("yaml", {
      s("task",
        fmta([[version: 3

      tasks:
      default: <cur>]], {
          cur = i(0)
        })),
    })

    ----------------------------------- RUST --------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("rust", {
      s("d",
        fmta("#[derive(<cur>)]", {
          cur = i(0),
        })
      ),
      s("cmp",
        fmta("#[derive(Component)]\nstruct <cur>", {
          cur = i(0),
        })
      ),
      s("sys",
        fmta([[fn <name>(query: Query<<&<comp>>>) {
        for <item> in &query {
          <cur>
        }
      }]], {
          name = i(1),
          comp = i(2),
          item = i(3),
          cur = i(0),
        })
      ),
    })

    ----------------------------------- ODIN --------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("odin", {
      s("---",
        fmta(
          "//--------------------------------------------------------------------------------------------------\n<cur>",
          {
            cur = i(0)
          })),
      s("**",
        fmta("/*\n<cur>*/", {
          cur = i(0)
        })),
      s("ie", fmta("if err != nil {\n\treturn <ret>\n}\n<final>", {
        ret = i(1),
        final = i(0)
      })),
      s("en", fmta("err != nil <final>", {
        final = i(0)
      })),
      s("p",
        fmta("package <name><cur>", {
          name = f(get_current_folder_name, {}, {}),
          cur = i(0)
        })),
      s("i",
        fmta('import "<cur>"', {
          cur = i(0)
        })),
      s("ic",
        fmta('import "core:<cur>"', {
          cur = i(0)
        })),
      s("iv",
        fmta('import "vendor:<cur>"', {
          cur = i(0)
        })),
      s("irl",
        fmta('import rl "vendor:raylib"<cur>', {
          cur = i(0)
        })),
      s("ib",
        fmta('import "base:<cur>"', {
          cur = i(0)
        })),
      s("rl",
        fmta('import rl "vendor:raylib"<cur>', {
          cur = i(0)
        })),
      s("pr",
        fmta('<fn> :: proc(<args>) <cur>', {
          fn = i(1, "fn"),
          args = i(2),
          cur = i(0)
        })),
      s("l",
        fmta('fmt.println(<cur>)', {
          cur = i(0)
        })),
      s("lf",
        fmta('fmt.printf("<fmt>\\n", <cur>)', {
          fmt = i(1),
          cur = i(0)
        })),
    })

    ------------------------------------ GO ---------------------------------------
    -------------------------------------------------------------------------------

    ls.add_snippets("go", {
      s("trig", c(1, {
        t("Ugh boring, a text node"),
        i(nil, "At least I can edit something now..."),
        f(function(args) return "Still only counts as text!!" end, {})
      })),

      -- s("i", fmta("if <err> != nil {\n\treturn <ret>\n}\n<final>", {
      --   err = i(1, "err"),
      --   ret = d(2, go_ret_vals_now_func, { 1 }),
      --   final = i(0)
      -- })),
      --

      s("ie", fmta("if err != nil {\n\treturn <ret>\n}\n<final>", {
        ret = i(1),
        final = i(0)
      })),

      s("iei", fmta("if errors.Is(err, <err>) {\n\treturn <ret>\n}\n<final>", {
        err = i(1),
        ret = i(2),
        final = i(0)
      })),

      s("io", fmta("if !ok {\n\treturn <ret>\n}\n<final>", {
        ret = i(1),
        final = i(0)
      })),

      s("iie", fmta("if err := <exec>; err != nil {\n\t<ret>\n}\n<final>", {
        exec = i(1),
        ret = i(2),
        final = i(0),
      })),

      s("en", fmta("err != nil <final>", {
        final = i(0)
      })),

      s("iep", fmta("if err != nil {\n\tpanic(err)\n}\n<final>", {
        final = i(0)
      })),

      s("iiep", fmta("if err := <exec>; err != nil {\n\tpanic(err)\n}\n<final>", {
        exec = i(1),
        final = i(0),
      })),

      s("iee", fmta("if err != nil {\n\treturn err\n}\n<final>", {
        final = i(0)
      })),

      -- s("i", fmta("for i := 0; i << <count>; i++ {\n\t<cur>\n}", {
      --   count = i(1, "10"),
      --   cur = i(0),
      -- })),

      s("t", fmta("func Test<fn>(t *testing.T) {\n\t<cur>\n}", {
        fn = i(1, "fn"),
        cur = i(0),
      })),

      s("tr", fmta('t.Run("<name>", func(t *testing.T) {\n\t<cur>\n})', {
        name = i(1),
        cur = i(0),
      })),

      s("ti", fmta([[
      import (
      "testing"

      . "github.com/onsi/ginkgo/v2"
      . "github.com/onsi/gomega"
      )

      <cur>
      ]], {
        cur = i(0),
      })),

      s("tit", fmta([[
      import (
      "testing"

      . "github.com/onsi/ginkgo/v2"
      . "github.com/onsi/gomega"
      )

      func TestPackage(t *testing.T) {
        RegisterFailHandler(Fail)
        RunSpecs(t, "<cur>")
      }
      ]], {
        cur = i(0),
      })),

      s("tdt", fmta([[
      var _ = DescribeTable("<name>",
      func(<args>) {
        Expect(<pass>).To(Equal(<want>))<cur>
      },
      Entry("<entryname>", <entryargs>),
      )
      ]], {
        name = i(1, "name"),
        args = i(2, "arg bool, want bool"),
        pass = i(3, "arg"),
        want = i(4, "want"),
        entryname = i(5),
        entryargs = i(6, "true, true"),
        cur = i(0),
      })),

      s("tt", fmta([[
      When("<when>", func() {
        BeforeEach(func() {
        })

        It("<it>", func() {
          <cur>
        })
      })

      ]], {
        when = i(1, "something"),
        it = i(2, "does something"),
        cur = i(0),
      })),

      s("tmt", fmta([[
      var _ = Describe("<name>", func() {
        var svc *service
        var repo *mocks.Repo

        BeforeEach(func() {
          repo = mocks.NewRepo(GinkgoT())
          svc = &service{
            repo: repo,
          }
        })

        When("positive case", func() {
          It("does good", func() {
            repo.EXPECT().GetCount(mock.Anything).Return(123, nil)
            <cur>
            err := svc.DoSomething(context.Background())
            Expect(err).ToNot(HaveOccurred())
          })
        })
      })
      ]], {
        name = i(1),
        cur = i(0),
      })),

      s("exp",
        fmta([[<cur>.EXPECT().<fn>(mock.Anything, <arg>).Return(<ret>)]], {
          cur = i(1),
          fn = i(2),
          arg = i(3),
          ret = i(0),
        })),

      s("txmock",
        fmta(
          [[<cur>.EXPECT().ExecInTx(mock.Anything, mock.Anything).RunAndReturn(func(ctx context.Context, fn func(context.Context) error) error {
        return fn(ctx)
      })]], {
            cur = i(0),
          })),

      s("sql", fmta([[
      query, args, err := <qb>.ToSql()
      if err != nil {
        return <ret>
      }
      <cur>
      ]], {
        qb = i(1),
        ret = i(2),
        cur = i(0),
      })),

      s("sql1", fmta([[
      sql, args, err := builder.ToSql()
      if err != nil {
        return err<ret>
      }
      <cur>
      ]], {
        ret = i(1),
        cur = i(0),
      })),

      s("sql2", fmta([[
      sql, args, err := builder.ToSql()
      if err != nil {
        return nil, err<ret>
      }
      <cur>
      ]], {
        ret = i(1),
        cur = i(0),
      })),

      s("f", fmta("func(<args>) <ret> {\n\t<cur>\n}", {
        args = i(1, ""),
        ret = i(2, ""),
        cur = i(0),
      })),

      s("ff", fmta("func <fn>(<args>) <ret> {\n\t<cur>\n}", {
        fn = i(1, "fn"),
        args = i(2, ""),
        ret = i(3, ""),
        cur = i(0),
      })),

      s("fe", fmta("func <fn>(<args>) (<ret>, error) {\n\t<cur>\n}", {
        fn = i(1, "fn"),
        args = i(2, ""),
        ret = i(3, "typ"),
        cur = i(0),
      })),

      s("m", fmta("func (<cls>) <fn>(<args>) <ret> {\n\t<cur>\n}", {
        cls = i(1, "cls"),
        fn = i(2, "fn"),
        args = i(3, ""),
        ret = i(4, ""),
        cur = i(0),
      })),

      s("ms", fmta("func (s *service) <fn>(<args>) <ret> {\n\t<cur>\n}", {
        fn = i(1, "fn"),
        args = i(2, ""),
        ret = i(3, ""),
        cur = i(0),
      })),

      s("mr", fmta("func (r *repo) <fn>(<args>) <ret> {\n\t<cur>\n}", {
        fn = i(1, "fn"),
        args = i(2, ""),
        ret = i(3, ""),
        cur = i(0),
      })),

      s("mm", fmta("func (<cls>) <fn>(<args>) (<ret>, <ret2>) {\n\t<cur>\n}", {
        cls = i(1, "cls"),
        fn = i(2, "fn"),
        args = i(3, ""),
        ret = i(4, "typ"),
        ret2 = i(5, "typ"),
        cur = i(0),
      })),

      s("me", fmta("func (<cls>) <fn>(<args>) (<ret>, error) {\n\t<cur>\n}", {
        cls = i(1, "cls"),
        fn = i(2, "fn"),
        args = i(3, ""),
        ret = i(4, "typ"),
        cur = i(0),
      })),

      s("ap", fmta("<slice> = append(<slice_rep>, <cur>)", {
        slice = i(1, "slice"),
        slice_rep = rep(1),
        cur = i(0)
      })),
      s("---",
        fmta(
          "//--------------------------------------------------------------------------------------------------\n<cur>",
          {
            cur = i(0)
          })),

      s("c", fmta("ctx context.Context<cur>", {
        cur = i(0),
      })),

      s("s", fmta("type <name> struct {\n\t<cur>\n}", {
        name = i(1),
        cur = i(0),
      })),

      s("i", fmta("type <name> interface {\n\t<cur>\n}", {
        name = i(1),
        cur = i(0),
      })),

      s("fc", fmta("func(ctx context.Context) error<cur>", {
        cur = i(0),
      })),

      s("ni", fmta("errors.New(\"not implemented\")<cur>", {
        cur = i(0),
      })),

      s("js", fmta([[`json:"<cur>"`]], {
        cur = i(0),
      })),

      s("mck", fmta("//go:generate mockery --dir=. --name=<name> --exported --with-expecter<cur>", {
        name = i(1, "name"),
        cur = i(0),
      })),

      s("e", fmta([[fmt.Errorf("<cur>: %w", err)]], {
        cur = i(0),
      })),

      s("geq", fmta([[Expect(<act>).To(Equal(<exp>))<cur>]], {
        act = i(1),
        exp = i(2),
        cur = i(0),
      })),

      s("ge", fmta([[Expect(err).ToNot(HaveOccurred())<cur>]], {
        cur = i(0),
      })),

      s("geo", fmta([[Expect(err).To(HaveOccurred())<cur>]], {
        cur = i(0),
      })),

      s("sas", fmta([["<name> AS <name_rep>",<cur>]], {
        name = i(1),
        name_rep = rep(1),
        cur = i(0),
      })),

      s("sex", fmta("<name> = EXCLUDED.<name_rep>,<cur>", {
        name = i(1),
        name_rep = rep(1),
        cur = i(0),
      })),

      s("gf", fmta("go func() {\n\t<cur>\n}()", {
        cur = i(0),
      })),
      s("df", fmta("defer func() {\n\t<cur>\n}()", {
        cur = i(0),
      })),
      s("sp", fmta("ctx, span := tracer.Start(ctx, \"<span>\")\ndefer span.End()\n<cur>", {
        span = i(1),
        cur = i(0),
      })),


      s("initlogger", fmta(require("plugins.bigsnip.go-logger").logger, {})),
    })


    -- ----------------------------------------------------------------------------


    vim.keymap.set("i", "<c-k>", function()
      if ls.expand_or_jumpable(1) then
        ls.expand_or_jump()
      end
    end)

    vim.keymap.set("i", "<c-j>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end)

    vim.keymap.set("i", "<c-l>", function()
      if ls.choice_active() then
        return ls.change_choice(1)
      end
    end)
    vim.keymap.set("i", "<c-s-l>", function()
      if ls.choice_active() then
        return ls.change_choice(-1)
      end
    end)
    -- vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>luasnip-next-choice", {})
    -- vim.api.nvim_set_keymap("i", "<C-S-l>", "<Plug>luasnip-prev-choice", {})

    ----------------
  end
}
