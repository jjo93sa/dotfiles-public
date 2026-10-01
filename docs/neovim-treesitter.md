# Neovim Treesitter guide

Treesitter parses a buffer into a syntax tree. Unlike regular-expression
highlighting, it knows that text is a function, parameter, conditional, YAML
key, Markdown heading, or embedded Jinja expression. Neovim and its plugins use
that tree for highlighting, indentation, selection, movement, text objects,
folding, and language injection.

Treesitter and an LSP solve different, complementary problems. Treesitter
understands the syntax already present in the current buffer. An LSP uses
project and type information to provide diagnostics, completion, definitions,
references, and renames. Treesitter therefore remains useful even when no
language server is running, while an LSP can make deeper semantic decisions.

In everyday work this means you can:

- expand a selection to the surrounding Python function or conditional;
- jump between Terraform resources and function calls;
- edit or reorder arguments without selecting punctuation by hand;
- fold Markdown sections or Terraform blocks structurally;
- inspect how YAML and embedded Jinja are being parsed when Ansible
  highlighting looks surprising.

## Language coverage

The managed parser set includes:

- Ansible and Jinja, using the Jinja parser with YAML injected between template
  expressions in playbooks and roles;
- Python;
- YAML;
- Terraform and Packer HCL;
- Markdown and inline Markdown;
- the other web, shell, Lua, Nix, Vim, Dockerfile, and query languages already
  used by this configuration.

Missing parsers are installed asynchronously when Neovim starts. Restart
Neovim after a first-time parser installation. Lazy updates the installed
parsers alongside `nvim-treesitter` via `:TSUpdate`.

## Incremental selection

Neovim 0.12 provides these mappings directly. Start Visual mode over some code,
then adjust the selection structurally:

| Mapping | Action |
| --- | --- |
| `an` | Select the parent syntax node |
| `in` | Select the child syntax node |
| `]n` / `[n` | Select the next / previous node |
| `]N` / `[N` | Extend through the next / previous sibling |

For example, place the cursor inside a Python expression, press `van` several
times to expand from the expression to its statement and surrounding block,
then use `in` to shrink the selection.

## Syntax-aware text objects

The text-object plugin makes normal Vim operators understand code structure.
Prefix any object with an operator such as `d`, `c`, or `y`, or use it after
entering Visual mode.

| Object | Meaning | Example |
| --- | --- | --- |
| `am` / `im` | Around / inside function or method | `dam` deletes a function |
| `ac` / `ic` | Around / inside class | `vic` selects a class body |
| `af` / `if` | Around / inside function call | `cif` changes call arguments |
| `aa` / `ia` | Around / inside parameter | `dia` deletes one argument |
| `ai` / `ii` | Around / inside conditional | `vai` selects an `if` block |
| `al` / `il` | Around / inside loop | `yil` copies a loop body |
| `a=` / `i=` | Around / inside assignment | `ci=` changes an assignment |
| `l=` / `r=` | Assignment left / right side | `yr=` copies its value |

Availability depends on the query support provided for the current language.

## Structural movement

| Mapping | Move to |
| --- | --- |
| `]m` / `[m` | Next / previous function or method definition |
| `]f` / `[f` | Next / previous function call |
| `]c` / `[c` | Next / previous class |
| `]i` / `[i` | Next / previous conditional |
| `]l` / `[l` | Next / previous loop |
| `]s` / `[s` | Next / previous scope |
| `]z` / `[z` | Next / previous foldable node |

Uppercase variants such as `]M` move to the end rather than the start. Repeat
the last structural movement with `;`, or reverse it with `,`.

## Swapping nodes

The leader key is `\\` in this configuration:

| Mapping | Action |
| --- | --- |
| `\\na` / `\\pa` | Swap an argument with the next / previous argument |
| `\\nm` / `\\pm` | Swap a function with the next / previous function |
| `\\n:` / `\\p:` | Swap an object property with the next / previous property |

## Folding and inspection

Treesitter folding is enabled automatically where the language supplies fold
queries (including Python, Terraform, Markdown, Nix, and several existing web
languages). YAML retains the dedicated indentation-aware YAML folding plugin.
Use Vim's standard fold commands:

- `za` toggles the fold under the cursor;
- `zc` and `zo` close and open it;
- `zM` and `zR` close and open all folds.

For understanding what Treesitter sees, run `:Inspect` on the item under the
cursor or `:InspectTree` to open the complete syntax tree. These are useful when
a text object is unavailable or highlighting behaves unexpectedly.

Use `:checkhealth nvim-treesitter` to inspect parser and query health. Run
`:TSUpdate` after updating the Treesitter plugins if Lazy did not already do so.
