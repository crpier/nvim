-- Static Catppuccin Macchiato colorscheme.
--
-- Attribution:
--   Derived from catppuccin/nvim: https://github.com/catppuccin/nvim
--   Source snapshot: commit 0303a7208dba448c459767486a38a6ec05c4216b
--   Copyright (c) 2021 Catppuccin
--   License: MIT
--
-- MIT License notice from upstream:
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
-- This is a generated highlight snapshot, not the full upstream plugin.

vim.o.termguicolors = true
vim.cmd.highlight "clear"
if vim.fn.exists "syntax_on" == 1 then
  vim.cmd.syntax "reset"
end
vim.g.colors_name = "catppuccin-macchiato"

local highlights = {
  ["@attribute"] = {
    link = "Constant",
  },
  ["@attribute.builtin"] = {
    link = "Special",
  },
  ["@attribute.c_sharp"] = {
    fg = "#eed49f",
  },
  ["@boolean"] = {
    link = "Boolean",
  },
  ["@character"] = {
    link = "Character",
  },
  ["@character.special"] = {
    link = "SpecialChar",
  },
  ["@character.special.html"] = {
    fg = "#ed8796",
  },
  ["@comment"] = {
    link = "Comment",
  },
  ["@comment.documentation"] = {
    link = "Comment",
  },
  ["@comment.error"] = {
    bg = "#ed8796",
    fg = "#24273a",
  },
  ["@comment.hint"] = {
    bg = "#8aadf4",
    fg = "#24273a",
  },
  ["@comment.note"] = {
    bg = "#8aadf4",
    fg = "#24273a",
  },
  ["@comment.todo"] = {
    bg = "#f0c6c6",
    fg = "#24273a",
  },
  ["@comment.warning"] = {
    bg = "#eed49f",
    fg = "#24273a",
  },
  ["@comment.warning.gitcommit"] = {
    fg = "#eed49f",
  },
  ["@conditional"] = {
    link = "Conditional",
  },
  ["@constant"] = {
    link = "Constant",
  },
  ["@constant.builtin"] = {
    fg = "#f5a97f",
  },
  ["@constant.java"] = {
    fg = "#8bd5ca",
  },
  ["@constant.macro"] = {
    link = "Macro",
  },
  ["@constructor"] = {
    fg = "#eed49f",
  },
  ["@constructor.lua"] = {
    link = "@punctuation.bracket",
  },
  ["@constructor.python"] = {
    fg = "#91d7e3",
  },
  ["@define"] = {
    link = "Define",
  },
  ["@diff.delta"] = {
    link = "diffChanged",
  },
  ["@diff.minus"] = {
    link = "diffRemoved",
  },
  ["@diff.plus"] = {
    link = "diffAdded",
  },
  ["@error"] = {
    link = "Error",
  },
  ["@exception"] = {
    link = "Exception",
  },
  ["@field"] = {
    fg = "#b7bdf8",
  },
  ["@float"] = {
    link = "Float",
  },
  ["@function"] = {
    link = "Function",
  },
  ["@function.builtin"] = {
    fg = "#f5a97f",
  },
  ["@function.builtin.bash"] = {
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["@function.call"] = {
    link = "Function",
  },
  ["@function.macro"] = {
    fg = "#f5bde6",
  },
  ["@function.method"] = {
    link = "Function",
  },
  ["@function.method.call"] = {
    link = "Function",
  },
  ["@function.method.call.php"] = {
    link = "Function",
  },
  ["@function.method.php"] = {
    link = "Function",
  },
  ["@include"] = {
    link = "Include",
  },
  ["@keyword"] = {
    link = "Keyword",
  },
  ["@keyword.conditional"] = {
    link = "Conditional",
  },
  ["@keyword.conditional.ternary"] = {
    link = "Operator",
  },
  ["@keyword.coroutine"] = {
    link = "Keyword",
  },
  ["@keyword.debug"] = {
    link = "Exception",
  },
  ["@keyword.directive"] = {
    link = "PreProc",
  },
  ["@keyword.directive.css"] = {
    link = "Keyword",
  },
  ["@keyword.directive.define"] = {
    link = "Define",
  },
  ["@keyword.exception"] = {
    link = "Exception",
  },
  ["@keyword.export"] = {
    fg = "#c6a0f6",
  },
  ["@keyword.function"] = {
    fg = "#c6a0f6",
  },
  ["@keyword.import"] = {
    link = "Include",
  },
  ["@keyword.import.c"] = {
    fg = "#eed49f",
  },
  ["@keyword.import.cpp"] = {
    fg = "#eed49f",
  },
  ["@keyword.modifier"] = {
    link = "Keyword",
  },
  ["@keyword.operator"] = {
    fg = "#c6a0f6",
  },
  ["@keyword.repeat"] = {
    link = "Repeat",
  },
  ["@keyword.return"] = {
    fg = "#c6a0f6",
  },
  ["@keyword.storage"] = {
    link = "Keyword",
  },
  ["@keyword.type"] = {
    link = "Keyword",
  },
  ["@label"] = {
    link = "Label",
  },
  ["@label.yaml"] = {
    fg = "#eed49f",
  },
  ["@lsp.mod.deprecated"] = {
    link = "DiagnosticDeprecated",
  },
  ["@lsp.type.class"] = {
    link = "@type",
  },
  ["@lsp.type.comment"] = {
    link = "@comment",
  },
  ["@lsp.type.decorator"] = {
    link = "@attribute",
  },
  ["@lsp.type.enum"] = {
    link = "@type",
  },
  ["@lsp.type.enumMember"] = {
    fg = "#8bd5ca",
  },
  ["@lsp.type.event"] = {
    link = "@type",
  },
  ["@lsp.type.function"] = {
    link = "@function",
  },
  ["@lsp.type.interface"] = {
    link = "@type",
  },
  ["@lsp.type.keyword"] = {
    link = "@keyword",
  },
  ["@lsp.type.macro"] = {
    link = "@constant.macro",
  },
  ["@lsp.type.method"] = {
    link = "@function.method",
  },
  ["@lsp.type.modifier"] = {
    link = "@type.qualifier",
  },
  ["@lsp.type.namespace"] = {
    link = "@module",
  },
  ["@lsp.type.number"] = {
    link = "@number",
  },
  ["@lsp.type.operator"] = {
    link = "@operator",
  },
  ["@lsp.type.parameter"] = {
    link = "@variable.parameter",
  },
  ["@lsp.type.property"] = {
    link = "@property",
  },
  ["@lsp.type.regexp"] = {
    link = "@string.regexp",
  },
  ["@lsp.type.string"] = {
    link = "@string",
  },
  ["@lsp.type.struct"] = {
    link = "@type",
  },
  ["@lsp.type.type"] = {
    link = "@type",
  },
  ["@lsp.type.typeParameter"] = {
    link = "@type.definition",
  },
  ["@lsp.typemod.function.builtin"] = {
    link = "@function.builtin",
  },
  ["@lsp.typemod.function.defaultLibrary"] = {
    link = "@function.builtin",
  },
  ["@markup"] = {
    fg = "#cad3f5",
  },
  ["@markup.environment"] = {
    fg = "#f5bde6",
  },
  ["@markup.environment.name"] = {
    fg = "#8aadf4",
  },
  ["@markup.heading"] = {
    fg = "#8aadf4",
  },
  ["@markup.heading.1.delimiter.vimdoc"] = {
    bg = "#24273a",
    cterm = {
      nocombine = true,
      underdouble = true,
    },
    fg = "#24273a",
    nocombine = true,
    sp = "#cad3f5",
    underdouble = true,
  },
  ["@markup.heading.1.html"] = {
    link = "@markup",
  },
  ["@markup.heading.1.markdown"] = {
    link = "rainbow1",
  },
  ["@markup.heading.2.delimiter.vimdoc"] = {
    bg = "#24273a",
    cterm = {
      nocombine = true,
      underline = true,
    },
    fg = "#24273a",
    nocombine = true,
    sp = "#cad3f5",
    underline = true,
  },
  ["@markup.heading.2.html"] = {
    link = "@markup",
  },
  ["@markup.heading.2.markdown"] = {
    link = "rainbow2",
  },
  ["@markup.heading.3.html"] = {
    link = "@markup",
  },
  ["@markup.heading.3.markdown"] = {
    link = "rainbow3",
  },
  ["@markup.heading.4.html"] = {
    link = "@markup",
  },
  ["@markup.heading.4.markdown"] = {
    link = "rainbow4",
  },
  ["@markup.heading.5.html"] = {
    link = "@markup",
  },
  ["@markup.heading.5.markdown"] = {
    link = "rainbow5",
  },
  ["@markup.heading.6.html"] = {
    link = "@markup",
  },
  ["@markup.heading.6.markdown"] = {
    link = "rainbow6",
  },
  ["@markup.heading.html"] = {
    link = "@markup",
  },
  ["@markup.heading.markdown"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["@markup.italic"] = {
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["@markup.link"] = {
    fg = "#b7bdf8",
  },
  ["@markup.link.label"] = {
    fg = "#b7bdf8",
  },
  ["@markup.link.label.html"] = {
    fg = "#cad3f5",
  },
  ["@markup.link.url"] = {
    cterm = {
      italic = true,
      underline = true,
    },
    fg = "#8aadf4",
    italic = true,
    underline = true,
  },
  ["@markup.list"] = {
    fg = "#8bd5ca",
  },
  ["@markup.list.checked"] = {
    fg = "#a6da95",
  },
  ["@markup.list.unchecked"] = {
    fg = "#8087a2",
  },
  ["@markup.math"] = {
    fg = "#8aadf4",
  },
  ["@markup.quote"] = {
    fg = "#f5bde6",
  },
  ["@markup.raw"] = {
    fg = "#a6da95",
  },
  ["@markup.strikethrough"] = {
    cterm = {
      strikethrough = true,
    },
    fg = "#cad3f5",
    strikethrough = true,
  },
  ["@markup.strong"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#ed8796",
  },
  ["@markup.underline"] = {
    link = "Underlined",
  },
  ["@method"] = {
    link = "Function",
  },
  ["@method.call"] = {
    link = "Function",
  },
  ["@method.call.php"] = {
    link = "Function",
  },
  ["@method.php"] = {
    link = "Function",
  },
  ["@module"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["@module.builtin"] = {
    link = "Special",
  },
  ["@namespace"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["@number"] = {
    link = "Number",
  },
  ["@number.css"] = {
    fg = "#f5a97f",
  },
  ["@number.float"] = {
    link = "Float",
  },
  ["@operator"] = {
    link = "Operator",
  },
  ["@parameter"] = {
    fg = "#ee99a0",
  },
  ["@preproc"] = {
    link = "PreProc",
  },
  ["@property"] = {
    fg = "#b7bdf8",
  },
  ["@property.class.css"] = {
    fg = "#eed49f",
  },
  ["@property.css"] = {
    fg = "#8aadf4",
  },
  ["@property.id.css"] = {
    fg = "#eed49f",
  },
  ["@property.scss"] = {
    fg = "#8aadf4",
  },
  ["@punctuation"] = {
    link = "Delimiter",
  },
  ["@punctuation.bracket"] = {
    fg = "#939ab7",
  },
  ["@punctuation.delimiter"] = {
    link = "Delimiter",
  },
  ["@punctuation.delimiter.regex"] = {
    link = "@string.regexp",
  },
  ["@punctuation.special"] = {
    link = "Special",
  },
  ["@repeat"] = {
    link = "Repeat",
  },
  ["@storageclass"] = {
    link = "Keyword",
  },
  ["@string"] = {
    link = "String",
  },
  ["@string.documentation"] = {
    fg = "#8bd5ca",
  },
  ["@string.escape"] = {
    fg = "#f5bde6",
  },
  ["@string.plain.css"] = {
    fg = "#cad3f5",
  },
  ["@string.regex"] = {
    fg = "#f5bde6",
  },
  ["@string.regexp"] = {
    fg = "#f5bde6",
  },
  ["@string.special"] = {
    link = "Special",
  },
  ["@string.special.path"] = {
    link = "Special",
  },
  ["@string.special.path.gitignore"] = {
    fg = "#cad3f5",
  },
  ["@string.special.symbol"] = {
    fg = "#f0c6c6",
  },
  ["@string.special.symbol.ruby"] = {
    fg = "#f0c6c6",
  },
  ["@string.special.url"] = {
    cterm = {
      italic = true,
      underline = true,
    },
    fg = "#8aadf4",
    italic = true,
    underline = true,
  },
  ["@string.special.url.html"] = {
    fg = "#a6da95",
  },
  ["@symbol"] = {
    fg = "#f0c6c6",
  },
  ["@symbol.ruby"] = {
    fg = "#f0c6c6",
  },
  ["@tag"] = {
    fg = "#8aadf4",
  },
  ["@tag.attribute"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["@tag.builtin"] = {
    fg = "#8aadf4",
  },
  ["@tag.delimiter"] = {
    fg = "#8bd5ca",
  },
  ["@text"] = {
    fg = "#cad3f5",
  },
  ["@text.danger"] = {
    bg = "#ed8796",
    fg = "#24273a",
  },
  ["@text.diff.add"] = {
    link = "diffAdded",
  },
  ["@text.diff.delete"] = {
    link = "diffRemoved",
  },
  ["@text.emphasis"] = {
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["@text.environment"] = {
    fg = "#f5bde6",
  },
  ["@text.environment.name"] = {
    fg = "#8aadf4",
  },
  ["@text.literal"] = {
    fg = "#a6da95",
  },
  ["@text.math"] = {
    fg = "#8aadf4",
  },
  ["@text.note"] = {
    bg = "#8aadf4",
    fg = "#24273a",
  },
  ["@text.reference"] = {
    fg = "#b7bdf8",
  },
  ["@text.strike"] = {
    cterm = {
      strikethrough = true,
    },
    fg = "#cad3f5",
    strikethrough = true,
  },
  ["@text.strong"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#ed8796",
  },
  ["@text.title"] = {
    fg = "#8aadf4",
  },
  ["@text.title.1.markdown"] = {
    link = "rainbow1",
  },
  ["@text.title.2.markdown"] = {
    link = "rainbow2",
  },
  ["@text.title.3.markdown"] = {
    link = "rainbow3",
  },
  ["@text.title.4.markdown"] = {
    link = "rainbow4",
  },
  ["@text.title.5.markdown"] = {
    link = "rainbow5",
  },
  ["@text.title.6.markdown"] = {
    link = "rainbow6",
  },
  ["@text.todo"] = {
    bg = "#f0c6c6",
    fg = "#24273a",
  },
  ["@text.todo.checked"] = {
    fg = "#a6da95",
  },
  ["@text.todo.unchecked"] = {
    fg = "#8087a2",
  },
  ["@text.underline"] = {
    link = "Underlined",
  },
  ["@text.warning"] = {
    bg = "#eed49f",
    fg = "#24273a",
  },
  ["@type"] = {
    link = "Type",
  },
  ["@type.builtin"] = {
    fg = "#c6a0f6",
  },
  ["@type.css"] = {
    fg = "#b7bdf8",
  },
  ["@type.definition"] = {
    link = "Type",
  },
  ["@type.qualifier"] = {
    link = "Keyword",
  },
  ["@type.tag.css"] = {
    fg = "#8aadf4",
  },
  ["@variable"] = {
    fg = "#cad3f5",
  },
  ["@variable.builtin"] = {
    fg = "#ed8796",
  },
  ["@variable.member"] = {
    fg = "#b7bdf8",
  },
  ["@variable.parameter"] = {
    fg = "#ee99a0",
  },
  ["@variable.parameter.bash"] = {
    fg = "#a6da95",
  },
  ["@variable.parameter.builtin"] = {
    link = "Special",
  },
  ["Added"] = {
    fg = "#a6da95",
  },
  ["AlphaButtons"] = {
    fg = "#b7bdf8",
  },
  ["AlphaFooter"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["AlphaHeader"] = {
    fg = "#8aadf4",
  },
  ["AlphaHeaderLabel"] = {
    fg = "#f5a97f",
  },
  ["AlphaShortcut"] = {
    fg = "#a6da95",
  },
  ["BlinkCmpDoc"] = {
    link = "NormalFloat",
  },
  ["BlinkCmpDocBorder"] = {
    link = "FloatBorder",
  },
  ["BlinkCmpKind"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindClass"] = {
    fg = "#eed49f",
  },
  ["BlinkCmpKindColor"] = {
    fg = "#ed8796",
  },
  ["BlinkCmpKindConstant"] = {
    fg = "#f5a97f",
  },
  ["BlinkCmpKindConstructor"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindCopilot"] = {
    fg = "#8bd5ca",
  },
  ["BlinkCmpKindEnum"] = {
    fg = "#eed49f",
  },
  ["BlinkCmpKindEnumMember"] = {
    fg = "#8bd5ca",
  },
  ["BlinkCmpKindEvent"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindField"] = {
    fg = "#a6da95",
  },
  ["BlinkCmpKindFile"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindFolder"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindFunction"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindInterface"] = {
    fg = "#eed49f",
  },
  ["BlinkCmpKindKeyword"] = {
    fg = "#c6a0f6",
  },
  ["BlinkCmpKindMethod"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindModule"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindOperator"] = {
    fg = "#91d7e3",
  },
  ["BlinkCmpKindProperty"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindReference"] = {
    fg = "#ed8796",
  },
  ["BlinkCmpKindSnippet"] = {
    fg = "#f0c6c6",
  },
  ["BlinkCmpKindStruct"] = {
    fg = "#8aadf4",
  },
  ["BlinkCmpKindText"] = {
    fg = "#a6da95",
  },
  ["BlinkCmpKindTypeParameter"] = {
    fg = "#ee99a0",
  },
  ["BlinkCmpKindUnit"] = {
    fg = "#a6da95",
  },
  ["BlinkCmpKindValue"] = {
    fg = "#f5a97f",
  },
  ["BlinkCmpKindVariable"] = {
    fg = "#f0c6c6",
  },
  ["BlinkCmpLabel"] = {
    fg = "#939ab7",
  },
  ["BlinkCmpLabelDeprecated"] = {
    cterm = {
      strikethrough = true,
    },
    fg = "#6e738d",
    strikethrough = true,
  },
  ["BlinkCmpLabelDescription"] = {
    link = "PmenuExtra",
  },
  ["BlinkCmpLabelDetail"] = {
    link = "PmenuExtra",
  },
  ["BlinkCmpLabelMatch"] = {
    link = "PmenuMatch",
  },
  ["BlinkCmpMenu"] = {
    link = "Pmenu",
  },
  ["BlinkCmpMenuBorder"] = {
    bg = "#1e2030",
    fg = "#8aadf4",
  },
  ["BlinkCmpMenuSelection"] = {
    bg = "#494d64",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["BlinkCmpScrollBarGutter"] = {
    bg = "#494d64",
  },
  ["BlinkCmpScrollBarThumb"] = {
    bg = "#6e738d",
  },
  ["BlinkCmpSignatureHelpBorder"] = {
    link = "FloatBorder",
  },
  ["BlinkIndent"] = {
    fg = "#363a4f",
  },
  ["BlinkIndentBlue"] = {
    fg = "#8aadf4",
  },
  ["BlinkIndentBlueUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#8aadf4",
    underline = true,
  },
  ["BlinkIndentCyan"] = {
    fg = "#91d7e3",
  },
  ["BlinkIndentCyanUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#91d7e3",
    underline = true,
  },
  ["BlinkIndentGreen"] = {
    fg = "#a6da95",
  },
  ["BlinkIndentGreenUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#a6da95",
    underline = true,
  },
  ["BlinkIndentOrange"] = {
    fg = "#f5a97f",
  },
  ["BlinkIndentOrangeUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#f5a97f",
    underline = true,
  },
  ["BlinkIndentRed"] = {
    fg = "#ed8796",
  },
  ["BlinkIndentRedUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#ed8796",
    underline = true,
  },
  ["BlinkIndentScope"] = {
    fg = "#939ab7",
  },
  ["BlinkIndentViolet"] = {
    fg = "#c6a0f6",
  },
  ["BlinkIndentVioletUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#c6a0f6",
    underline = true,
  },
  ["BlinkIndentYellow"] = {
    fg = "#eed49f",
  },
  ["BlinkIndentYellowUnderline"] = {
    cterm = {
      underline = true,
    },
    sp = "#eed49f",
    underline = true,
  },
  ["Bold"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["Boolean"] = {
    fg = "#f5a97f",
  },
  ["Changed"] = {
    fg = "#8aadf4",
  },
  ["Character"] = {
    fg = "#8bd5ca",
  },
  ["CmpItemAbbr"] = {
    fg = "#939ab7",
  },
  ["CmpItemAbbrDeprecated"] = {
    cterm = {
      strikethrough = true,
    },
    fg = "#6e738d",
    strikethrough = true,
  },
  ["CmpItemAbbrMatch"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#cad3f5",
  },
  ["CmpItemAbbrMatchFuzzy"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#cad3f5",
  },
  ["CmpItemKind"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindClass"] = {
    fg = "#eed49f",
  },
  ["CmpItemKindColor"] = {
    fg = "#ed8796",
  },
  ["CmpItemKindConstant"] = {
    fg = "#f5a97f",
  },
  ["CmpItemKindConstructor"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindCopilot"] = {
    fg = "#8bd5ca",
  },
  ["CmpItemKindEnum"] = {
    fg = "#a6da95",
  },
  ["CmpItemKindEnumMember"] = {
    fg = "#ed8796",
  },
  ["CmpItemKindEvent"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindField"] = {
    fg = "#a6da95",
  },
  ["CmpItemKindFile"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindFolder"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindFunction"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindInterface"] = {
    fg = "#eed49f",
  },
  ["CmpItemKindKeyword"] = {
    fg = "#ed8796",
  },
  ["CmpItemKindMethod"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindModule"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindOperator"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindProperty"] = {
    fg = "#a6da95",
  },
  ["CmpItemKindReference"] = {
    fg = "#ed8796",
  },
  ["CmpItemKindSnippet"] = {
    fg = "#c6a0f6",
  },
  ["CmpItemKindStruct"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindText"] = {
    fg = "#8bd5ca",
  },
  ["CmpItemKindTypeParameter"] = {
    fg = "#8aadf4",
  },
  ["CmpItemKindUnit"] = {
    fg = "#a6da95",
  },
  ["CmpItemKindValue"] = {
    fg = "#f5a97f",
  },
  ["CmpItemKindVariable"] = {
    fg = "#f0c6c6",
  },
  ["CmpItemMenu"] = {
    fg = "#cad3f5",
  },
  ["ColorColumn"] = {
    bg = "#363a4f",
  },
  ["Comment"] = {
    cterm = {
      italic = true,
    },
    fg = "#939ab7",
    italic = true,
  },
  ["ComplHint"] = {
    fg = "#a5adcb",
  },
  ["ComplHintMore"] = {
    link = "Question",
  },
  ["ComplMatchIns"] = {
    link = "PreInsert",
  },
  ["Conceal"] = {
    fg = "#8087a2",
  },
  ["Conditional"] = {
    cterm = {
      italic = true,
    },
    fg = "#c6a0f6",
    italic = true,
  },
  ["Constant"] = {
    fg = "#f5a97f",
  },
  ["CurSearch"] = {
    bg = "#ed8796",
    fg = "#1e2030",
  },
  ["Cursor"] = {
    bg = "#f4dbd6",
    fg = "#24273a",
  },
  ["CursorColumn"] = {
    bg = "#1e2030",
  },
  ["CursorIM"] = {
    bg = "#f4dbd6",
    fg = "#24273a",
  },
  ["CursorLine"] = {
    bg = "#303347",
  },
  ["CursorLineFold"] = {
    link = "FoldColumn",
  },
  ["CursorLineNr"] = {
    fg = "#b7bdf8",
  },
  ["CursorLineSign"] = {
    link = "SignColumn",
  },
  ["DapBreakpoint"] = {
    fg = "#ed8796",
  },
  ["DapBreakpointCondition"] = {
    fg = "#eed49f",
  },
  ["DapBreakpointRejected"] = {
    fg = "#c6a0f6",
  },
  ["DapLogPoint"] = {
    fg = "#91d7e3",
  },
  ["DapStopped"] = {
    fg = "#ee99a0",
  },
  ["DapUIBreakpointsCurrentLine"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["DapUIBreakpointsDisabledLine"] = {
    fg = "#5b6078",
  },
  ["DapUIBreakpointsInfo"] = {
    fg = "#a6da95",
  },
  ["DapUIBreakpointsPath"] = {
    fg = "#91d7e3",
  },
  ["DapUIDecoration"] = {
    fg = "#91d7e3",
  },
  ["DapUIFloatBorder"] = {
    link = "FloatBorder",
  },
  ["DapUILineNumber"] = {
    fg = "#91d7e3",
  },
  ["DapUIModifiedValue"] = {
    fg = "#f5a97f",
  },
  ["DapUIPlayPause"] = {
    fg = "#a6da95",
  },
  ["DapUIPlayPauseNC"] = {
    link = "DapUIPlayPause",
  },
  ["DapUIRestart"] = {
    fg = "#a6da95",
  },
  ["DapUIRestartNC"] = {
    link = "DapUIRestart",
  },
  ["DapUIScope"] = {
    fg = "#91d7e3",
  },
  ["DapUISource"] = {
    fg = "#b7bdf8",
  },
  ["DapUIStepBack"] = {
    fg = "#8aadf4",
  },
  ["DapUIStepBackNC"] = {
    link = "DapUIStepBack",
  },
  ["DapUIStepInto"] = {
    fg = "#8aadf4",
  },
  ["DapUIStepIntoNC"] = {
    link = "DapUIStepInto",
  },
  ["DapUIStepOut"] = {
    fg = "#8aadf4",
  },
  ["DapUIStepOutNC"] = {
    link = "DapUIStepOut",
  },
  ["DapUIStepOver"] = {
    fg = "#8aadf4",
  },
  ["DapUIStepOverNC"] = {
    link = "DapUIStepOver",
  },
  ["DapUIStop"] = {
    fg = "#ed8796",
  },
  ["DapUIStopNC"] = {
    link = "DapUIStop",
  },
  ["DapUIStoppedThread"] = {
    fg = "#91d7e3",
  },
  ["DapUIThread"] = {
    fg = "#a6da95",
  },
  ["DapUIType"] = {
    fg = "#c6a0f6",
  },
  ["DapUIUnavailable"] = {
    fg = "#494d64",
  },
  ["DapUIUnavailableNC"] = {
    link = "DapUIUnavailable",
  },
  ["DapUIValue"] = {
    fg = "#91d7e3",
  },
  ["DapUIVariable"] = {
    fg = "#cad3f5",
  },
  ["DapUIWatchesEmpty"] = {
    fg = "#ee99a0",
  },
  ["DapUIWatchesError"] = {
    fg = "#ee99a0",
  },
  ["DapUIWatchesValue"] = {
    fg = "#a6da95",
  },
  ["DapUIWinSelect"] = {
    fg = "#f5a97f",
  },
  ["DashboardCenter"] = {
    fg = "#a6da95",
  },
  ["DashboardDesc"] = {
    fg = "#8aadf4",
  },
  ["DashboardFiles"] = {
    fg = "#b7bdf8",
  },
  ["DashboardFooter"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["DashboardHeader"] = {
    fg = "#8aadf4",
  },
  ["DashboardIcon"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5bde6",
  },
  ["DashboardKey"] = {
    fg = "#f5a97f",
  },
  ["DashboardMruTitle"] = {
    fg = "#91d7e3",
  },
  ["DashboardProjectTitle"] = {
    fg = "#91d7e3",
  },
  ["DashboardShortCut"] = {
    fg = "#f5bde6",
  },
  ["Debug"] = {
    link = "Special",
  },
  ["Define"] = {
    link = "PreProc",
  },
  ["Delimiter"] = {
    fg = "#939ab7",
  },
  ["DiagnosticDeprecated"] = {
    cterm = {
      strikethrough = true,
    },
    sp = "#ffc0b9",
    strikethrough = true,
  },
  ["DiagnosticError"] = {
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["DiagnosticFloatingError"] = {
    fg = "#ed8796",
  },
  ["DiagnosticFloatingHint"] = {
    fg = "#8bd5ca",
  },
  ["DiagnosticFloatingInfo"] = {
    fg = "#91d7e3",
  },
  ["DiagnosticFloatingOk"] = {
    fg = "#a6da95",
  },
  ["DiagnosticFloatingWarn"] = {
    fg = "#eed49f",
  },
  ["DiagnosticHint"] = {
    cterm = {
      italic = true,
    },
    fg = "#8bd5ca",
    italic = true,
  },
  ["DiagnosticInfo"] = {
    cterm = {
      italic = true,
    },
    fg = "#91d7e3",
    italic = true,
  },
  ["DiagnosticOk"] = {
    cterm = {
      italic = true,
    },
    fg = "#a6da95",
    italic = true,
  },
  ["DiagnosticSignError"] = {
    fg = "#ed8796",
  },
  ["DiagnosticSignHint"] = {
    fg = "#8bd5ca",
  },
  ["DiagnosticSignInfo"] = {
    fg = "#91d7e3",
  },
  ["DiagnosticSignOk"] = {
    fg = "#a6da95",
  },
  ["DiagnosticSignWarn"] = {
    fg = "#eed49f",
  },
  ["DiagnosticUnderlineError"] = {
    cterm = {
      underline = true,
    },
    sp = "#ed8796",
    underline = true,
  },
  ["DiagnosticUnderlineHint"] = {
    cterm = {
      underline = true,
    },
    sp = "#8bd5ca",
    underline = true,
  },
  ["DiagnosticUnderlineInfo"] = {
    cterm = {
      underline = true,
    },
    sp = "#91d7e3",
    underline = true,
  },
  ["DiagnosticUnderlineOk"] = {
    cterm = {
      underline = true,
    },
    sp = "#a6da95",
    underline = true,
  },
  ["DiagnosticUnderlineWarn"] = {
    cterm = {
      underline = true,
    },
    sp = "#eed49f",
    underline = true,
  },
  ["DiagnosticUnnecessary"] = {
    link = "Comment",
  },
  ["DiagnosticVirtualLinesError"] = {
    link = "DiagnosticError",
  },
  ["DiagnosticVirtualLinesHint"] = {
    link = "DiagnosticHint",
  },
  ["DiagnosticVirtualLinesInfo"] = {
    link = "DiagnosticInfo",
  },
  ["DiagnosticVirtualLinesOk"] = {
    link = "DiagnosticOk",
  },
  ["DiagnosticVirtualLinesWarn"] = {
    link = "DiagnosticWarn",
  },
  ["DiagnosticVirtualTextError"] = {
    bg = "#373043",
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["DiagnosticVirtualTextHint"] = {
    bg = "#2e3848",
    cterm = {
      italic = true,
    },
    fg = "#8bd5ca",
    italic = true,
  },
  ["DiagnosticVirtualTextInfo"] = {
    bg = "#2e384a",
    cterm = {
      italic = true,
    },
    fg = "#91d7e3",
    italic = true,
  },
  ["DiagnosticVirtualTextOk"] = {
    bg = "#2e3848",
    cterm = {
      italic = true,
    },
    fg = "#a6da95",
    italic = true,
  },
  ["DiagnosticVirtualTextWarn"] = {
    bg = "#373744",
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["DiagnosticWarn"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["DiffAdd"] = {
    bg = "#3b474a",
  },
  ["DiffChange"] = {
    bg = "#2b3047",
  },
  ["DiffDelete"] = {
    bg = "#48384b",
  },
  ["DiffText"] = {
    bg = "#434f72",
  },
  ["DiffTextAdd"] = {
    link = "DiffText",
  },
  ["Dimmed"] = {
    fg = "#8087a2",
  },
  ["Directory"] = {
    fg = "#8aadf4",
  },
  ["DropBarIconUISeparator"] = {
    fg = "#8087a2",
  },
  ["DropBarKindArray"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindBoolean"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindBreakStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindCall"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindCaseStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindClass"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindConstant"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindConstructor"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindContinueStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindDeclaration"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindDelete"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindDoStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindElseStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindEnum"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindEnumMember"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindEvent"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindField"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindFile"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindFolder"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindForStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindFunction"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindIdentifier"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindIfStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindInterface"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindKeyword"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindList"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMacro"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH1"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH2"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH3"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH4"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH5"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMarkdownH6"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindMethod"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindModule"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindNamespace"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindNull"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindNumber"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindObject"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindOperator"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindPackage"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindProperty"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindReference"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindRepeat"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindScope"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindSpecifier"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindString"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindStruct"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindSwitchStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindType"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindTypeParameter"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindUnit"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindValue"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindVariable"] = {
    fg = "#cad3f5",
  },
  ["DropBarKindWhileStatement"] = {
    fg = "#cad3f5",
  },
  ["DropBarMenuHoverEntry"] = {
    link = "Visual",
  },
  ["DropBarMenuHoverIcon"] = {
    cterm = {
      reverse = true,
    },
    reverse = true,
  },
  ["DropBarMenuHoverSymbol"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["EndOfBuffer"] = {
    fg = "#494d64",
  },
  ["Error"] = {
    fg = "#ed8796",
  },
  ["ErrorMsg"] = {
    bold = true,
    cterm = {
      bold = true,
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["Exception"] = {
    fg = "#c6a0f6",
  },
  ["FlashBackdrop"] = {
    fg = "#6e738d",
  },
  ["FlashCurrent"] = {
    bg = "#24273a",
    fg = "#f5a97f",
  },
  ["FlashLabel"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["FlashMatch"] = {
    bg = "#24273a",
    fg = "#b7bdf8",
  },
  ["FlashPrompt"] = {
    link = "NormalFloat",
  },
  ["Float"] = {
    link = "Number",
  },
  ["FloatBorder"] = {
    bg = "#1e2030",
    fg = "#8aadf4",
  },
  ["FloatFooter"] = {
    link = "FloatTitle",
  },
  ["FloatShadow"] = {
    bg = "#6e738d",
    blend = 80,
  },
  ["FloatShadowThrough"] = {
    bg = "#6e738d",
    blend = 100,
  },
  ["FloatTitle"] = {
    bg = "#1e2030",
    fg = "#a5adcb",
  },
  ["FoldColumn"] = {
    fg = "#6e738d",
  },
  ["Folded"] = {
    bg = "#494d64",
    fg = "#8aadf4",
  },
  ["Function"] = {
    fg = "#8aadf4",
  },
  ["FzfLuaBorder"] = {
    link = "FloatBorder",
  },
  ["FzfLuaBufFlagAlt"] = {
    fg = "#8aadf4",
  },
  ["FzfLuaBufFlagCur"] = {
    fg = "#f5a97f",
  },
  ["FzfLuaBufName"] = {
    fg = "#c6a0f6",
  },
  ["FzfLuaBufNr"] = {
    fg = "#eed49f",
  },
  ["FzfLuaDirPart"] = {
    link = "NonText",
  },
  ["FzfLuaFzfMatch"] = {
    fg = "#8aadf4",
  },
  ["FzfLuaFzfPrompt"] = {
    fg = "#8aadf4",
  },
  ["FzfLuaHeaderBind"] = {
    fg = "#eed49f",
  },
  ["FzfLuaHeaderText"] = {
    fg = "#f5a97f",
  },
  ["FzfLuaLiveSym"] = {
    fg = "#f5a97f",
  },
  ["FzfLuaNormal"] = {
    link = "NormalFloat",
  },
  ["FzfLuaPathColNr"] = {
    fg = "#8aadf4",
  },
  ["FzfLuaPathLineNr"] = {
    fg = "#a6da95",
  },
  ["FzfLuaTabMarker"] = {
    fg = "#eed49f",
  },
  ["FzfLuaTabTitle"] = {
    fg = "#91d7e3",
  },
  ["FzfLuaTitle"] = {
    link = "FloatTitle",
  },
  ["GitSignsAdd"] = {
    fg = "#a6da95",
  },
  ["GitSignsAddInline"] = {
    bg = "#53675b",
  },
  ["GitSignsAddPreview"] = {
    link = "DiffAdd",
  },
  ["GitSignsChange"] = {
    fg = "#eed49f",
  },
  ["GitSignsChangeInline"] = {
    bg = "#323a54",
  },
  ["GitSignsCurrentLineBlame"] = {
    fg = "#494d64",
  },
  ["GitSignsDelete"] = {
    fg = "#ed8796",
  },
  ["GitSignsDeleteInline"] = {
    bg = "#6c4a5b",
  },
  ["GitSignsDeletePreview"] = {
    link = "DiffDelete",
  },
  ["GlyphPalette1"] = {
    fg = "#ed8796",
  },
  ["GlyphPalette2"] = {
    fg = "#8bd5ca",
  },
  ["GlyphPalette3"] = {
    fg = "#eed49f",
  },
  ["GlyphPalette4"] = {
    fg = "#8aadf4",
  },
  ["GlyphPalette6"] = {
    fg = "#8bd5ca",
  },
  ["GlyphPalette7"] = {
    fg = "#cad3f5",
  },
  ["GlyphPalette9"] = {
    fg = "#ed8796",
  },
  ["IblIndent"] = {
    fg = "#363a4f",
  },
  ["IblScope"] = {
    fg = "#cad3f5",
  },
  ["Identifier"] = {
    fg = "#f0c6c6",
  },
  ["Ignore"] = {
    link = "Normal",
  },
  ["IlluminatedWordRead"] = {
    bg = "#3e4257",
  },
  ["IlluminatedWordText"] = {
    bg = "#3e4257",
  },
  ["IlluminatedWordWrite"] = {
    bg = "#3e4257",
  },
  ["IncSearch"] = {
    bg = "#86c5d2",
    fg = "#1e2030",
  },
  ["Include"] = {
    fg = "#c6a0f6",
  },
  ["Italic"] = {
    cterm = {
      italic = true,
    },
    italic = true,
  },
  ["Keyword"] = {
    fg = "#c6a0f6",
  },
  ["Label"] = {
    fg = "#7dc4e4",
  },
  ["LineNr"] = {
    fg = "#494d64",
  },
  ["LineNrAbove"] = {
    link = "LineNr",
  },
  ["LineNrBelow"] = {
    link = "LineNr",
  },
  ["LspCodeLens"] = {
    fg = "#6e738d",
  },
  ["LspCodeLensSeparator"] = {
    link = "LspCodeLens",
  },
  ["LspDiagnosticsDefaultError"] = {
    fg = "#ed8796",
  },
  ["LspDiagnosticsDefaultHint"] = {
    fg = "#8bd5ca",
  },
  ["LspDiagnosticsDefaultInformation"] = {
    fg = "#91d7e3",
  },
  ["LspDiagnosticsDefaultWarning"] = {
    fg = "#eed49f",
  },
  ["LspDiagnosticsError"] = {
    fg = "#ed8796",
  },
  ["LspDiagnosticsHint"] = {
    fg = "#8bd5ca",
  },
  ["LspDiagnosticsInformation"] = {
    fg = "#91d7e3",
  },
  ["LspDiagnosticsUnderlineError"] = {
    cterm = {
      underline = true,
    },
    sp = "#ed8796",
    underline = true,
  },
  ["LspDiagnosticsUnderlineHint"] = {
    cterm = {
      underline = true,
    },
    sp = "#8bd5ca",
    underline = true,
  },
  ["LspDiagnosticsUnderlineInformation"] = {
    cterm = {
      underline = true,
    },
    sp = "#91d7e3",
    underline = true,
  },
  ["LspDiagnosticsUnderlineWarning"] = {
    cterm = {
      underline = true,
    },
    sp = "#eed49f",
    underline = true,
  },
  ["LspDiagnosticsVirtualTextError"] = {
    cterm = {
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["LspDiagnosticsVirtualTextHint"] = {
    cterm = {
      italic = true,
    },
    fg = "#8bd5ca",
    italic = true,
  },
  ["LspDiagnosticsVirtualTextInformation"] = {
    cterm = {
      italic = true,
    },
    fg = "#91d7e3",
    italic = true,
  },
  ["LspDiagnosticsVirtualTextWarning"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["LspDiagnosticsWarning"] = {
    fg = "#eed49f",
  },
  ["LspInfoBorder"] = {
    link = "FloatBorder",
  },
  ["LspInlayHint"] = {
    bg = "#303347",
    fg = "#6e738d",
  },
  ["LspReferenceRead"] = {
    bg = "#494d64",
  },
  ["LspReferenceTarget"] = {
    link = "LspReferenceText",
  },
  ["LspReferenceText"] = {
    bg = "#494d64",
  },
  ["LspReferenceWrite"] = {
    bg = "#494d64",
  },
  ["LspSignatureActiveParameter"] = {
    bg = "#363a4f",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["Macro"] = {
    fg = "#c6a0f6",
  },
  ["MatchParen"] = {
    bg = "#3e4257",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5a97f",
  },
  ["MiniAnimateCursor"] = {
    cterm = {
      nocombine = true,
      reverse = true,
    },
    nocombine = true,
    reverse = true,
  },
  ["MiniAnimateNormalFloat"] = {
    link = "NormalFloat",
  },
  ["MiniClueBorder"] = {
    link = "FloatBorder",
  },
  ["MiniClueDescGroup"] = {
    link = "DiagnosticFloatingWarn",
  },
  ["MiniClueDescSingle"] = {
    link = "NormalFloat",
  },
  ["MiniClueNextKey"] = {
    link = "DiagnosticFloatingHint",
  },
  ["MiniClueNextKeyWithPostkeys"] = {
    link = "DiagnosticFloatingError",
  },
  ["MiniClueSeparator"] = {
    link = "DiagnosticFloatingInfo",
  },
  ["MiniClueTitle"] = {
    link = "FloatTitle",
  },
  ["MiniCompletionActiveParameter"] = {
    cterm = {
      underline = true,
    },
    underline = true,
  },
  ["MiniCursorword"] = {
    cterm = {
      underline = true,
    },
    underline = true,
  },
  ["MiniCursorwordCurrent"] = {
    cterm = {
      underline = true,
    },
    underline = true,
  },
  ["MiniDepsChangeAdded"] = {
    link = "diffAdded",
  },
  ["MiniDepsChangeRemoved"] = {
    link = "diffRemoved",
  },
  ["MiniDepsHint"] = {
    link = "DiagnosticHint",
  },
  ["MiniDepsInfo"] = {
    link = "DiagnosticInfo",
  },
  ["MiniDepsMsgBreaking"] = {
    link = "DiagnosticWarn",
  },
  ["MiniDepsPlaceholder"] = {
    link = "Comment",
  },
  ["MiniDepsTitle"] = {
    link = "Title",
  },
  ["MiniDepsTitleError"] = {
    bg = "#ed8796",
    fg = "#24273a",
  },
  ["MiniDepsTitleSame"] = {
    link = "DiffText",
  },
  ["MiniDepsTitleUpdate"] = {
    bg = "#a6da95",
    fg = "#24273a",
  },
  ["MiniDiffOverAdd"] = {
    link = "DiffAdd",
  },
  ["MiniDiffOverChange"] = {
    link = "DiffText",
  },
  ["MiniDiffOverContext"] = {
    link = "DiffChange",
  },
  ["MiniDiffOverDelete"] = {
    link = "DiffDelete",
  },
  ["MiniDiffSignAdd"] = {
    fg = "#a6da95",
  },
  ["MiniDiffSignChange"] = {
    fg = "#eed49f",
  },
  ["MiniDiffSignDelete"] = {
    fg = "#ed8796",
  },
  ["MiniFilesBorder"] = {
    link = "FloatBorder",
  },
  ["MiniFilesBorderModified"] = {
    link = "DiagnosticFloatingWarn",
  },
  ["MiniFilesCursorLine"] = {
    link = "CursorLine",
  },
  ["MiniFilesDirectory"] = {
    link = "Directory",
  },
  ["MiniFilesFile"] = {
    fg = "#cad3f5",
  },
  ["MiniFilesNormal"] = {
    link = "NormalFloat",
  },
  ["MiniFilesTitle"] = {
    link = "FloatTitle",
  },
  ["MiniFilesTitleFocused"] = {
    bg = "#1e2030",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a5adcb",
  },
  ["MiniHipatternsFixme"] = {
    bg = "#ed8796",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniHipatternsHack"] = {
    bg = "#eed49f",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniHipatternsNote"] = {
    bg = "#91d7e3",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniHipatternsTodo"] = {
    bg = "#8bd5ca",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniIconsAzure"] = {
    fg = "#7dc4e4",
  },
  ["MiniIconsBlue"] = {
    fg = "#8aadf4",
  },
  ["MiniIconsCyan"] = {
    fg = "#8bd5ca",
  },
  ["MiniIconsGreen"] = {
    fg = "#a6da95",
  },
  ["MiniIconsGrey"] = {
    fg = "#cad3f5",
  },
  ["MiniIconsOrange"] = {
    fg = "#f5a97f",
  },
  ["MiniIconsPurple"] = {
    fg = "#c6a0f6",
  },
  ["MiniIconsRed"] = {
    fg = "#ed8796",
  },
  ["MiniIconsYellow"] = {
    fg = "#eed49f",
  },
  ["MiniIndentscopeSymbol"] = {
    fg = "#939ab7",
  },
  ["MiniJump"] = {
    bg = "#f5bde6",
    fg = "#939ab7",
  },
  ["MiniJump2dDim"] = {
    fg = "#6e738d",
  },
  ["MiniJump2dSpot"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
      underline = true,
    },
    fg = "#f5a97f",
    underline = true,
  },
  ["MiniJump2dSpotAhead"] = {
    bg = "#1f2132",
    fg = "#8bd5ca",
  },
  ["MiniJump2dSpotUnique"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#91d7e3",
  },
  ["MiniMapNormal"] = {
    link = "NormalFloat",
  },
  ["MiniMapSymbolCount"] = {
    link = "Special",
  },
  ["MiniMapSymbolLine"] = {
    link = "Title",
  },
  ["MiniMapSymbolView"] = {
    link = "Delimiter",
  },
  ["MiniNotifyBorder"] = {
    link = "FloatBorder",
  },
  ["MiniNotifyNormal"] = {
    link = "NormalFloat",
  },
  ["MiniNotifyTitle"] = {
    link = "FloatTitle",
  },
  ["MiniOperatorsExchangeFrom"] = {
    link = "IncSearch",
  },
  ["MiniPickBorder"] = {
    link = "FloatBorder",
  },
  ["MiniPickBorderBusy"] = {
    link = "DiagnosticFloatingWarn",
  },
  ["MiniPickBorderText"] = {
    bg = "#1e2030",
    fg = "#c6a0f6",
  },
  ["MiniPickHeader"] = {
    link = "DiagnosticFloatingHint",
  },
  ["MiniPickIconDirectory"] = {
    link = "Directory",
  },
  ["MiniPickIconFile"] = {
    link = "MiniPickNormal",
  },
  ["MiniPickMatchCurrent"] = {
    bg = "#363a4f",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f0c6c6",
  },
  ["MiniPickMatchMarked"] = {
    link = "Visual",
  },
  ["MiniPickMatchRanges"] = {
    link = "DiagnosticFloatingHint",
  },
  ["MiniPickNormal"] = {
    link = "NormalFloat",
  },
  ["MiniPickPreviewLine"] = {
    link = "CursorLine",
  },
  ["MiniPickPreviewRegion"] = {
    link = "IncSearch",
  },
  ["MiniPickPrompt"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["MiniPickPromptCaret"] = {
    bg = "#1e2030",
    fg = "#f0c6c6",
  },
  ["MiniPickPromptPrefix"] = {
    bg = "#1e2030",
    fg = "#f0c6c6",
  },
  ["MiniStarterFooter"] = {
    cterm = {
      italic = true,
    },
    fg = "#eed49f",
    italic = true,
  },
  ["MiniStarterHeader"] = {
    fg = "#8aadf4",
  },
  ["MiniStarterInactive"] = {
    cterm = {
      italic = true,
    },
    fg = "#5b6078",
    italic = true,
  },
  ["MiniStarterItem"] = {
    fg = "#cad3f5",
  },
  ["MiniStarterItemBullet"] = {
    fg = "#8aadf4",
  },
  ["MiniStarterItemPrefix"] = {
    fg = "#f5bde6",
  },
  ["MiniStarterQuery"] = {
    fg = "#a6da95",
  },
  ["MiniStarterSection"] = {
    fg = "#f0c6c6",
  },
  ["MiniStatuslineDevinfo"] = {
    bg = "#494d64",
    fg = "#b8c0e0",
  },
  ["MiniStatuslineFileinfo"] = {
    bg = "#494d64",
    fg = "#b8c0e0",
  },
  ["MiniStatuslineFilename"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["MiniStatuslineInactive"] = {
    bg = "#1e2030",
    fg = "#8aadf4",
  },
  ["MiniStatuslineModeCommand"] = {
    bg = "#f5a97f",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniStatuslineModeInsert"] = {
    bg = "#a6da95",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniStatuslineModeNormal"] = {
    bg = "#8aadf4",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#1e2030",
  },
  ["MiniStatuslineModeOther"] = {
    bg = "#8bd5ca",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniStatuslineModeReplace"] = {
    bg = "#ed8796",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniStatuslineModeVisual"] = {
    bg = "#c6a0f6",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["MiniSurround"] = {
    bg = "#f5bde6",
    fg = "#494d64",
  },
  ["MiniTablineCurrent"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
      italic = true,
      underline = true,
    },
    fg = "#cad3f5",
    italic = true,
    sp = "#ed8796",
    underline = true,
  },
  ["MiniTablineFill"] = {
    bg = "#24273a",
  },
  ["MiniTablineHidden"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["MiniTablineModifiedCurrent"] = {
    bold = true,
    cterm = {
      bold = true,
      italic = true,
    },
    fg = "#ed8796",
    italic = true,
  },
  ["MiniTablineModifiedHidden"] = {
    fg = "#ed8796",
  },
  ["MiniTablineModifiedVisible"] = {
    fg = "#ed8796",
  },
  ["MiniTablineTabpagesection"] = {
    bg = "#24273a",
    fg = "#494d64",
  },
  ["MiniTestEmphasis"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["MiniTestFail"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#ed8796",
  },
  ["MiniTestPass"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["MiniTrailspace"] = {
    bg = "#ed8796",
  },
  ["ModeMsg"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#cad3f5",
  },
  ["MoreMsg"] = {
    fg = "#8aadf4",
  },
  ["MsgSeparator"] = {
    link = "WinSeparator",
  },
  ["NeoTreeDimText"] = {
    fg = "#8087a2",
  },
  ["NeoTreeDirectoryIcon"] = {
    fg = "#8aadf4",
  },
  ["NeoTreeDirectoryName"] = {
    fg = "#8aadf4",
  },
  ["NeoTreeExpander"] = {
    fg = "#6e738d",
  },
  ["NeoTreeFileNameOpened"] = {
    fg = "#f5bde6",
  },
  ["NeoTreeFilterTerm"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["NeoTreeFloatBorder"] = {
    link = "FloatBorder",
  },
  ["NeoTreeFloatTitle"] = {
    link = "FloatTitle",
  },
  ["NeoTreeGitAdded"] = {
    fg = "#a6da95",
  },
  ["NeoTreeGitConflict"] = {
    fg = "#ed8796",
  },
  ["NeoTreeGitDeleted"] = {
    fg = "#ed8796",
  },
  ["NeoTreeGitIgnored"] = {
    fg = "#6e738d",
  },
  ["NeoTreeGitModified"] = {
    fg = "#eed49f",
  },
  ["NeoTreeGitStaged"] = {
    fg = "#a6da95",
  },
  ["NeoTreeGitUnstaged"] = {
    fg = "#ed8796",
  },
  ["NeoTreeGitUntracked"] = {
    fg = "#c6a0f6",
  },
  ["NeoTreeIndentMarker"] = {
    fg = "#6e738d",
  },
  ["NeoTreeModified"] = {
    fg = "#f5a97f",
  },
  ["NeoTreeNormal"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["NeoTreeNormalNC"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["NeoTreeRootName"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["NeoTreeStatusLineNC"] = {
    bg = "#1e2030",
    fg = "#1e2030",
  },
  ["NeoTreeSymbolicLinkTarget"] = {
    fg = "#f5bde6",
  },
  ["NeoTreeTabActive"] = {
    bg = "#1e2030",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b7bdf8",
  },
  ["NeoTreeTabInactive"] = {
    bg = "#24273a",
    fg = "#6e738d",
  },
  ["NeoTreeTabSeparatorActive"] = {
    bg = "#1e2030",
    fg = "#1e2030",
  },
  ["NeoTreeTabSeparatorInactive"] = {
    bg = "#24273a",
    fg = "#24273a",
  },
  ["NeoTreeTitleBar"] = {
    bg = "#8aadf4",
    fg = "#1e2030",
  },
  ["NeoTreeVertSplit"] = {
    bg = "#24273a",
    fg = "#24273a",
  },
  ["NeoTreeWinSeparator"] = {
    bg = "#24273a",
    fg = "#24273a",
  },
  ["NeogitBranch"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5a97f",
  },
  ["NeogitChangeAdded"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["NeogitChangeBothModified"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#eed49f",
  },
  ["NeogitChangeCopied"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5bde6",
  },
  ["NeogitChangeDeleted"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#ed8796",
  },
  ["NeogitChangeModified"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["NeogitChangeNewFile"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["NeogitChangeRenamed"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitChangeUpdated"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5a97f",
  },
  ["NeogitCommitViewHeader"] = {
    bg = "#434f72",
    fg = "#97b5f4",
  },
  ["NeogitDiffAdd"] = {
    bg = "#303843",
    fg = "#8cb683",
  },
  ["NeogitDiffAddHighlight"] = {
    bg = "#516559",
    fg = "#abd9a3",
  },
  ["NeogitDiffAddInline"] = {
    bg = "#658168",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["NeogitDiffContext"] = {
    bg = "#24273a",
  },
  ["NeogitDiffContextHighlight"] = {
    bg = "#363a4f",
  },
  ["NeogitDiffDelete"] = {
    bg = "#373043",
    fg = "#c57484",
  },
  ["NeogitDiffDeleteHighlight"] = {
    bg = "#69485a",
    fg = "#e892a4",
  },
  ["NeogitDiffDeleteInline"] = {
    bg = "#895768",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["NeogitDiffHeader"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["NeogitDiffHeaderHighlight"] = {
    bg = "#24273a",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5a97f",
  },
  ["NeogitFilePath"] = {
    cterm = {
      italic = true,
    },
    fg = "#8aadf4",
    italic = true,
  },
  ["NeogitGraphBlue"] = {
    fg = "#8aadf4",
  },
  ["NeogitGraphBoldBlue"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["NeogitGraphBoldCyan"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["NeogitGraphBoldGray"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b8c0e0",
  },
  ["NeogitGraphBoldGreen"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["NeogitGraphBoldPurple"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b7bdf8",
  },
  ["NeogitGraphBoldRed"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#ed8796",
  },
  ["NeogitGraphBoldWhite"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["NeogitGraphBoldYellow"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#eed49f",
  },
  ["NeogitGraphCyan"] = {
    fg = "#8aadf4",
  },
  ["NeogitGraphGray"] = {
    fg = "#b8c0e0",
  },
  ["NeogitGraphGreen"] = {
    fg = "#a6da95",
  },
  ["NeogitGraphOrange"] = {
    fg = "#f5a97f",
  },
  ["NeogitGraphPurple"] = {
    fg = "#b7bdf8",
  },
  ["NeogitGraphRed"] = {
    fg = "#ed8796",
  },
  ["NeogitGraphWhite"] = {
    fg = "#24273a",
  },
  ["NeogitGraphYellow"] = {
    fg = "#eed49f",
  },
  ["NeogitHunkHeader"] = {
    bg = "#2e344c",
    fg = "#576a97",
  },
  ["NeogitHunkHeaderHighlight"] = {
    bg = "#3a4462",
    fg = "#8aadf4",
  },
  ["NeogitNotificationError"] = {
    fg = "#ed8796",
  },
  ["NeogitNotificationInfo"] = {
    fg = "#8aadf4",
  },
  ["NeogitNotificationWarning"] = {
    fg = "#eed49f",
  },
  ["NeogitObjectId"] = {
    link = "Comment",
  },
  ["NeogitPopupActionKey"] = {
    fg = "#b7bdf8",
  },
  ["NeogitPopupBold"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["NeogitPopupConfigKey"] = {
    fg = "#b7bdf8",
  },
  ["NeogitPopupOptionKey"] = {
    fg = "#b7bdf8",
  },
  ["NeogitPopupSwitchKey"] = {
    fg = "#b7bdf8",
  },
  ["NeogitRebaseDone"] = {
    link = "Comment",
  },
  ["NeogitRebasing"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitRecentcommits"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitRemote"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#a6da95",
  },
  ["NeogitSectionHeader"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitStagedchanges"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitStash"] = {
    link = "Comment",
  },
  ["NeogitStashes"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitTagDistance"] = {
    fg = "#8aadf4",
  },
  ["NeogitTagName"] = {
    fg = "#eed49f",
  },
  ["NeogitUnmergedInto"] = {
    link = "Function",
  },
  ["NeogitUnmergedchanges"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitUnpulledFrom"] = {
    link = "Function",
  },
  ["NeogitUnpulledchanges"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitUnpushedTo"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b7bdf8",
  },
  ["NeogitUnstagedchanges"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitUntrackedfiles"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#c6a0f6",
  },
  ["NeogitWinSeparator"] = {
    link = "WinSeparator",
  },
  ["NonText"] = {
    fg = "#6e738d",
  },
  ["Normal"] = {
    bg = "#24273a",
    fg = "#cad3f5",
  },
  ["NormalFloat"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["NormalNC"] = {
    bg = "#24273a",
    fg = "#cad3f5",
  },
  ["NormalSB"] = {
    bg = "#181926",
    fg = "#cad3f5",
  },
  ["Number"] = {
    fg = "#f5a97f",
  },
  ["NvimAnd"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimArrow"] = {
    link = "Delimiter",
  },
  ["NvimAssignment"] = {
    link = "Operator",
  },
  ["NvimAssignmentWithAddition"] = {
    link = "NvimAugmentedAssignment",
  },
  ["NvimAssignmentWithConcatenation"] = {
    link = "NvimAugmentedAssignment",
  },
  ["NvimAssignmentWithSubtraction"] = {
    link = "NvimAugmentedAssignment",
  },
  ["NvimAugmentedAssignment"] = {
    link = "NvimAssignment",
  },
  ["NvimBinaryMinus"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimBinaryOperator"] = {
    link = "NvimOperator",
  },
  ["NvimBinaryPlus"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimCallingParenthesis"] = {
    link = "NvimParenthesis",
  },
  ["NvimColon"] = {
    link = "Delimiter",
  },
  ["NvimComma"] = {
    link = "Delimiter",
  },
  ["NvimComparison"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimComparisonModifier"] = {
    link = "NvimComparison",
  },
  ["NvimConcat"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimConcatOrSubscript"] = {
    link = "NvimConcat",
  },
  ["NvimContainer"] = {
    link = "NvimParenthesis",
  },
  ["NvimCurly"] = {
    link = "NvimSubscript",
  },
  ["NvimDict"] = {
    link = "NvimContainer",
  },
  ["NvimDivision"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimDoubleQuote"] = {
    link = "NvimStringQuote",
  },
  ["NvimDoubleQuotedBody"] = {
    link = "NvimStringBody",
  },
  ["NvimDoubleQuotedEscape"] = {
    link = "NvimStringSpecial",
  },
  ["NvimDoubleQuotedUnknownEscape"] = {
    link = "NvimInvalidValue",
  },
  ["NvimEnvironmentName"] = {
    link = "NvimIdentifier",
  },
  ["NvimEnvironmentSigil"] = {
    link = "NvimOptionSigil",
  },
  ["NvimFigureBrace"] = {
    link = "NvimInternalError",
  },
  ["NvimFloat"] = {
    link = "NvimNumber",
  },
  ["NvimIdentifier"] = {
    link = "Identifier",
  },
  ["NvimIdentifierKey"] = {
    link = "NvimIdentifier",
  },
  ["NvimIdentifierName"] = {
    link = "NvimIdentifier",
  },
  ["NvimIdentifierScope"] = {
    link = "NvimIdentifier",
  },
  ["NvimIdentifierScopeDelimiter"] = {
    link = "NvimIdentifier",
  },
  ["NvimInternalError"] = {
    bg = "#ff0000",
    ctermbg = 9,
    ctermfg = 9,
    fg = "#ff0000",
  },
  ["NvimInvalid"] = {
    link = "Error",
  },
  ["NvimInvalidAnd"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidArrow"] = {
    link = "NvimInvalidDelimiter",
  },
  ["NvimInvalidAssignment"] = {
    link = "NvimInvalid",
  },
  ["NvimInvalidAssignmentWithAddition"] = {
    link = "NvimInvalidAugmentedAssignment",
  },
  ["NvimInvalidAssignmentWithConcatenation"] = {
    link = "NvimInvalidAugmentedAssignment",
  },
  ["NvimInvalidAssignmentWithSubtraction"] = {
    link = "NvimInvalidAugmentedAssignment",
  },
  ["NvimInvalidAugmentedAssignment"] = {
    link = "NvimInvalidAssignment",
  },
  ["NvimInvalidBinaryMinus"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidBinaryOperator"] = {
    link = "NvimInvalidOperator",
  },
  ["NvimInvalidBinaryPlus"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidCallingParenthesis"] = {
    link = "NvimInvalidParenthesis",
  },
  ["NvimInvalidColon"] = {
    link = "NvimInvalidDelimiter",
  },
  ["NvimInvalidComma"] = {
    link = "NvimInvalidDelimiter",
  },
  ["NvimInvalidComparison"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidComparisonModifier"] = {
    link = "NvimInvalidComparison",
  },
  ["NvimInvalidConcat"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidConcatOrSubscript"] = {
    link = "NvimInvalidConcat",
  },
  ["NvimInvalidContainer"] = {
    link = "NvimInvalidParenthesis",
  },
  ["NvimInvalidCurly"] = {
    link = "NvimInvalidSubscript",
  },
  ["NvimInvalidDelimiter"] = {
    link = "NvimInvalid",
  },
  ["NvimInvalidDict"] = {
    link = "NvimInvalidContainer",
  },
  ["NvimInvalidDivision"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidDoubleQuote"] = {
    link = "NvimInvalidStringQuote",
  },
  ["NvimInvalidDoubleQuotedBody"] = {
    link = "NvimInvalidStringBody",
  },
  ["NvimInvalidDoubleQuotedEscape"] = {
    link = "NvimInvalidStringSpecial",
  },
  ["NvimInvalidDoubleQuotedUnknownEscape"] = {
    link = "NvimInvalidValue",
  },
  ["NvimInvalidEnvironmentName"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidEnvironmentSigil"] = {
    link = "NvimInvalidOptionSigil",
  },
  ["NvimInvalidFigureBrace"] = {
    link = "NvimInvalidDelimiter",
  },
  ["NvimInvalidFloat"] = {
    link = "NvimInvalidNumber",
  },
  ["NvimInvalidIdentifier"] = {
    link = "NvimInvalidValue",
  },
  ["NvimInvalidIdentifierKey"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidIdentifierName"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidIdentifierScope"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidIdentifierScopeDelimiter"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidLambda"] = {
    link = "NvimInvalidParenthesis",
  },
  ["NvimInvalidList"] = {
    link = "NvimInvalidContainer",
  },
  ["NvimInvalidMod"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidMultiplication"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidNestingParenthesis"] = {
    link = "NvimInvalidParenthesis",
  },
  ["NvimInvalidNot"] = {
    link = "NvimInvalidUnaryOperator",
  },
  ["NvimInvalidNumber"] = {
    link = "NvimInvalidValue",
  },
  ["NvimInvalidNumberPrefix"] = {
    link = "NvimInvalidNumber",
  },
  ["NvimInvalidOperator"] = {
    link = "NvimInvalid",
  },
  ["NvimInvalidOptionName"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidOptionScope"] = {
    link = "NvimInvalidIdentifierScope",
  },
  ["NvimInvalidOptionScopeDelimiter"] = {
    link = "NvimInvalidIdentifierScopeDelimiter",
  },
  ["NvimInvalidOptionSigil"] = {
    link = "NvimInvalidIdentifier",
  },
  ["NvimInvalidOr"] = {
    link = "NvimInvalidBinaryOperator",
  },
  ["NvimInvalidParenthesis"] = {
    link = "NvimInvalidDelimiter",
  },
  ["NvimInvalidPlainAssignment"] = {
    link = "NvimInvalidAssignment",
  },
  ["NvimInvalidRegister"] = {
    link = "NvimInvalidValue",
  },
  ["NvimInvalidSingleQuote"] = {
    link = "NvimInvalidStringQuote",
  },
  ["NvimInvalidSingleQuotedBody"] = {
    link = "NvimInvalidStringBody",
  },
  ["NvimInvalidSingleQuotedQuote"] = {
    link = "NvimInvalidStringSpecial",
  },
  ["NvimInvalidSingleQuotedUnknownEscape"] = {
    link = "NvimInternalError",
  },
  ["NvimInvalidSpacing"] = {
    link = "ErrorMsg",
  },
  ["NvimInvalidString"] = {
    link = "NvimInvalidValue",
  },
  ["NvimInvalidStringBody"] = {
    link = "NvimStringBody",
  },
  ["NvimInvalidStringQuote"] = {
    link = "NvimInvalidString",
  },
  ["NvimInvalidStringSpecial"] = {
    link = "NvimStringSpecial",
  },
  ["NvimInvalidSubscript"] = {
    link = "NvimInvalidParenthesis",
  },
  ["NvimInvalidSubscriptBracket"] = {
    link = "NvimInvalidSubscript",
  },
  ["NvimInvalidSubscriptColon"] = {
    link = "NvimInvalidSubscript",
  },
  ["NvimInvalidTernary"] = {
    link = "NvimInvalidOperator",
  },
  ["NvimInvalidTernaryColon"] = {
    link = "NvimInvalidTernary",
  },
  ["NvimInvalidUnaryMinus"] = {
    link = "NvimInvalidUnaryOperator",
  },
  ["NvimInvalidUnaryOperator"] = {
    link = "NvimInvalidOperator",
  },
  ["NvimInvalidUnaryPlus"] = {
    link = "NvimInvalidUnaryOperator",
  },
  ["NvimInvalidValue"] = {
    link = "NvimInvalid",
  },
  ["NvimLambda"] = {
    link = "NvimParenthesis",
  },
  ["NvimList"] = {
    link = "NvimContainer",
  },
  ["NvimMod"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimMultiplication"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimNestingParenthesis"] = {
    link = "NvimParenthesis",
  },
  ["NvimNot"] = {
    link = "NvimUnaryOperator",
  },
  ["NvimNumber"] = {
    link = "Number",
  },
  ["NvimNumberPrefix"] = {
    link = "Type",
  },
  ["NvimOperator"] = {
    link = "Operator",
  },
  ["NvimOptionName"] = {
    link = "NvimIdentifier",
  },
  ["NvimOptionScope"] = {
    link = "NvimIdentifierScope",
  },
  ["NvimOptionScopeDelimiter"] = {
    link = "NvimIdentifierScopeDelimiter",
  },
  ["NvimOptionSigil"] = {
    link = "Type",
  },
  ["NvimOr"] = {
    link = "NvimBinaryOperator",
  },
  ["NvimParenthesis"] = {
    link = "Delimiter",
  },
  ["NvimPlainAssignment"] = {
    link = "NvimAssignment",
  },
  ["NvimRegister"] = {
    link = "SpecialChar",
  },
  ["NvimSingleQuote"] = {
    link = "NvimStringQuote",
  },
  ["NvimSingleQuotedBody"] = {
    link = "NvimStringBody",
  },
  ["NvimSingleQuotedQuote"] = {
    link = "NvimStringSpecial",
  },
  ["NvimSingleQuotedUnknownEscape"] = {
    link = "NvimInternalError",
  },
  ["NvimSpacing"] = {
    link = "Normal",
  },
  ["NvimString"] = {
    link = "String",
  },
  ["NvimStringBody"] = {
    link = "NvimString",
  },
  ["NvimStringQuote"] = {
    link = "NvimString",
  },
  ["NvimStringSpecial"] = {
    link = "SpecialChar",
  },
  ["NvimSubscript"] = {
    link = "NvimParenthesis",
  },
  ["NvimSubscriptBracket"] = {
    link = "NvimSubscript",
  },
  ["NvimSubscriptColon"] = {
    link = "NvimSubscript",
  },
  ["NvimTernary"] = {
    link = "NvimOperator",
  },
  ["NvimTernaryColon"] = {
    link = "NvimTernary",
  },
  ["NvimTreeEmptyFolderName"] = {
    fg = "#8aadf4",
  },
  ["NvimTreeFolderIcon"] = {
    fg = "#8aadf4",
  },
  ["NvimTreeFolderName"] = {
    fg = "#8aadf4",
  },
  ["NvimTreeGitDeleted"] = {
    fg = "#ed8796",
  },
  ["NvimTreeGitDirty"] = {
    fg = "#eed49f",
  },
  ["NvimTreeGitNew"] = {
    fg = "#8aadf4",
  },
  ["NvimTreeImageFile"] = {
    fg = "#cad3f5",
  },
  ["NvimTreeIndentMarker"] = {
    fg = "#6e738d",
  },
  ["NvimTreeNormal"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["NvimTreeOpenedFile"] = {
    fg = "#f5bde6",
  },
  ["NvimTreeOpenedFolderName"] = {
    fg = "#8aadf4",
  },
  ["NvimTreeRootFolder"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b7bdf8",
  },
  ["NvimTreeSpecialFile"] = {
    fg = "#f0c6c6",
  },
  ["NvimTreeStatuslineNc"] = {
    bg = "#1e2030",
    fg = "#1e2030",
  },
  ["NvimTreeSymlink"] = {
    fg = "#f5bde6",
  },
  ["NvimTreeWinSeparator"] = {
    bg = "#24273a",
    fg = "#24273a",
  },
  ["NvimUnaryMinus"] = {
    link = "NvimUnaryOperator",
  },
  ["NvimUnaryOperator"] = {
    link = "NvimOperator",
  },
  ["NvimUnaryPlus"] = {
    link = "NvimUnaryOperator",
  },
  ["OkMsg"] = {
    ctermfg = 10,
    fg = "#b3f6c0",
  },
  ["Operator"] = {
    fg = "#91d7e3",
  },
  ["Pmenu"] = {
    bg = "#1e2030",
    fg = "#939ab7",
  },
  ["PmenuBorder"] = {
    bg = "#1e2030",
    fg = "#8aadf4",
  },
  ["PmenuExtra"] = {
    fg = "#6e738d",
  },
  ["PmenuExtraSel"] = {
    bg = "#363a4f",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#6e738d",
  },
  ["PmenuKind"] = {
    link = "Pmenu",
  },
  ["PmenuKindSel"] = {
    link = "PmenuSel",
  },
  ["PmenuMatch"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#cad3f5",
  },
  ["PmenuMatchSel"] = {
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["PmenuSbar"] = {
    bg = "#363a4f",
  },
  ["PmenuSel"] = {
    bg = "#363a4f",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["PmenuShadow"] = {
    link = "FloatShadow",
  },
  ["PmenuShadowThrough"] = {
    link = "FloatShadowThrough",
  },
  ["PmenuThumb"] = {
    bg = "#6e738d",
  },
  ["PreCondit"] = {
    link = "PreProc",
  },
  ["PreInsert"] = {
    fg = "#939ab7",
  },
  ["PreProc"] = {
    fg = "#f5bde6",
  },
  ["Question"] = {
    fg = "#8aadf4",
  },
  ["QuickFixLine"] = {
    bg = "#3e4257",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["RainbowDelimiterBlue"] = {
    fg = "#8aadf4",
  },
  ["RainbowDelimiterCyan"] = {
    fg = "#8bd5ca",
  },
  ["RainbowDelimiterGreen"] = {
    fg = "#a6da95",
  },
  ["RainbowDelimiterOrange"] = {
    fg = "#f5a97f",
  },
  ["RainbowDelimiterRed"] = {
    fg = "#ed8796",
  },
  ["RainbowDelimiterViolet"] = {
    fg = "#c6a0f6",
  },
  ["RainbowDelimiterYellow"] = {
    fg = "#eed49f",
  },
  ["RedrawDebugClear"] = {
    bg = "#6b5300",
    ctermbg = 11,
    ctermfg = 0,
  },
  ["RedrawDebugComposed"] = {
    bg = "#005523",
    ctermbg = 10,
    ctermfg = 0,
  },
  ["RedrawDebugNormal"] = {
    cterm = {
      reverse = true,
    },
    reverse = true,
  },
  ["RedrawDebugRecompose"] = {
    bg = "#590008",
    ctermbg = 9,
    ctermfg = 0,
  },
  ["Removed"] = {
    ctermfg = 9,
    fg = "#ffc0b9",
  },
  ["RenderMarkdownBullet"] = {
    fg = "#91d7e3",
  },
  ["RenderMarkdownCode"] = {
    bg = "#1e2030",
  },
  ["RenderMarkdownCodeInline"] = {
    bg = "#363a4f",
  },
  ["RenderMarkdownError"] = {
    fg = "#ed8796",
  },
  ["RenderMarkdownH1"] = {
    fg = "#ed8796",
  },
  ["RenderMarkdownH1Bg"] = {
    bg = "#373043",
  },
  ["RenderMarkdownH2"] = {
    fg = "#f5a97f",
  },
  ["RenderMarkdownH2Bg"] = {
    bg = "#383341",
  },
  ["RenderMarkdownH3"] = {
    fg = "#eed49f",
  },
  ["RenderMarkdownH3Bg"] = {
    bg = "#373744",
  },
  ["RenderMarkdownH4"] = {
    fg = "#a6da95",
  },
  ["RenderMarkdownH4Bg"] = {
    bg = "#303843",
  },
  ["RenderMarkdownH5"] = {
    fg = "#7dc4e4",
  },
  ["RenderMarkdownH5Bg"] = {
    bg = "#2c364a",
  },
  ["RenderMarkdownH6"] = {
    fg = "#b7bdf8",
  },
  ["RenderMarkdownH6Bg"] = {
    bg = "#32354c",
  },
  ["RenderMarkdownHint"] = {
    fg = "#8bd5ca",
  },
  ["RenderMarkdownInfo"] = {
    fg = "#91d7e3",
  },
  ["RenderMarkdownSuccess"] = {
    fg = "#a6da95",
  },
  ["RenderMarkdownTableHead"] = {
    fg = "#8aadf4",
  },
  ["RenderMarkdownTableRow"] = {
    fg = "#b7bdf8",
  },
  ["RenderMarkdownWarn"] = {
    fg = "#eed49f",
  },
  ["Repeat"] = {
    fg = "#c6a0f6",
  },
  ["Search"] = {
    bg = "#455c6d",
    fg = "#cad3f5",
  },
  ["SignColumn"] = {
    fg = "#494d64",
  },
  ["SignColumnSB"] = {
    bg = "#181926",
    fg = "#494d64",
  },
  ["SnippetTabstop"] = {
    link = "Visual",
  },
  ["SnippetTabstopActive"] = {
    link = "SnippetTabstop",
  },
  ["Special"] = {
    fg = "#f5bde6",
  },
  ["SpecialChar"] = {
    link = "Special",
  },
  ["SpecialComment"] = {
    link = "Special",
  },
  ["SpecialKey"] = {
    link = "NonText",
  },
  ["SpellBad"] = {
    cterm = {
      undercurl = true,
    },
    sp = "#ed8796",
    undercurl = true,
  },
  ["SpellCap"] = {
    cterm = {
      undercurl = true,
    },
    sp = "#eed49f",
    undercurl = true,
  },
  ["SpellLocal"] = {
    cterm = {
      undercurl = true,
    },
    sp = "#8aadf4",
    undercurl = true,
  },
  ["SpellRare"] = {
    cterm = {
      undercurl = true,
    },
    sp = "#a6da95",
    undercurl = true,
  },
  ["Statement"] = {
    fg = "#c6a0f6",
  },
  ["StatusLine"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["StatusLineNC"] = {
    bg = "#1e2030",
    fg = "#494d64",
  },
  ["StatusLineTerm"] = {
    link = "StatusLine",
  },
  ["StatusLineTermNC"] = {
    link = "StatusLineNC",
  },
  ["StderrMsg"] = {
    link = "ErrorMsg",
  },
  ["StorageClass"] = {
    fg = "#eed49f",
  },
  ["String"] = {
    fg = "#a6da95",
  },
  ["Structure"] = {
    fg = "#eed49f",
  },
  ["Substitute"] = {
    bg = "#494d64",
    fg = "#f5bde6",
  },
  ["TabLine"] = {
    bg = "#181926",
    fg = "#6e738d",
  },
  ["TabLineFill"] = {
    bg = "#1e2030",
  },
  ["TabLineSel"] = {
    link = "Normal",
  },
  ["Tag"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#b7bdf8",
  },
  ["TelescopeBorder"] = {
    link = "FloatBorder",
  },
  ["TelescopeMatching"] = {
    fg = "#8aadf4",
  },
  ["TelescopeNormal"] = {
    link = "NormalFloat",
  },
  ["TelescopePreviewNormal"] = {
    link = "TelescopeNormal",
  },
  ["TelescopePromptNormal"] = {
    link = "TelescopeNormal",
  },
  ["TelescopePromptPrefix"] = {
    fg = "#f0c6c6",
  },
  ["TelescopeResultsNormal"] = {
    link = "TelescopeNormal",
  },
  ["TelescopeSelection"] = {
    bg = "#363a4f",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f0c6c6",
  },
  ["TelescopeSelectionCaret"] = {
    bg = "#363a4f",
    fg = "#f0c6c6",
  },
  ["TelescopeTitle"] = {
    link = "FloatTitle",
  },
  ["TermCursor"] = {
    bg = "#f4dbd6",
    fg = "#24273a",
  },
  ["TermCursorNC"] = {
    bg = "#939ab7",
    fg = "#24273a",
  },
  ["Title"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["Todo"] = {
    bg = "#f0c6c6",
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#24273a",
  },
  ["TreesitterContext"] = {
    bg = "#1e2030",
    fg = "#cad3f5",
  },
  ["TreesitterContextBottom"] = {
    cterm = {
      underline = true,
    },
    sp = "#363a4f",
    underline = true,
  },
  ["TreesitterContextLineNumber"] = {
    bg = "#1e2030",
    fg = "#494d64",
  },
  ["Type"] = {
    fg = "#eed49f",
  },
  ["Typedef"] = {
    link = "Type",
  },
  ["UfoFoldedEllipsis"] = {
    bg = "#8aadf4",
    fg = "#181926",
  },
  ["UfoFoldedFg"] = {
    fg = "#b7bdf8",
  },
  ["Underlined"] = {
    cterm = {
      underline = true,
    },
    underline = true,
  },
  ["VertSplit"] = {
    fg = "#181926",
  },
  ["Visual"] = {
    bg = "#494d64",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["VisualNOS"] = {
    bg = "#494d64",
    bold = true,
    cterm = {
      bold = true,
    },
  },
  ["WarningMsg"] = {
    fg = "#eed49f",
  },
  ["Whitespace"] = {
    fg = "#494d64",
  },
  ["WildMenu"] = {
    bg = "#6e738d",
  },
  ["WinBar"] = {
    fg = "#f4dbd6",
  },
  ["WinBarNC"] = {
    link = "WinBar",
  },
  ["WinSeparator"] = {
    fg = "#181926",
  },
  ["csvCol0"] = {
    fg = "#ed8796",
  },
  ["csvCol1"] = {
    fg = "#f5a97f",
  },
  ["csvCol2"] = {
    fg = "#eed49f",
  },
  ["csvCol3"] = {
    fg = "#a6da95",
  },
  ["csvCol4"] = {
    fg = "#91d7e3",
  },
  ["csvCol5"] = {
    fg = "#8aadf4",
  },
  ["csvCol6"] = {
    fg = "#b7bdf8",
  },
  ["csvCol7"] = {
    fg = "#c6a0f6",
  },
  ["csvCol8"] = {
    fg = "#f5bde6",
  },
  ["debugBreakpoint"] = {
    bg = "#24273a",
    fg = "#6e738d",
  },
  ["debugPC"] = {
    bg = "#181926",
  },
  ["diffAdded"] = {
    fg = "#a6da95",
  },
  ["diffChanged"] = {
    fg = "#8aadf4",
  },
  ["diffFile"] = {
    fg = "#8aadf4",
  },
  ["diffIndexLine"] = {
    fg = "#8bd5ca",
  },
  ["diffLine"] = {
    fg = "#6e738d",
  },
  ["diffNewFile"] = {
    fg = "#f5a97f",
  },
  ["diffOldFile"] = {
    fg = "#eed49f",
  },
  ["diffRemoved"] = {
    fg = "#ed8796",
  },
  ["gitcommitSummary"] = {
    cterm = {
      italic = true,
    },
    fg = "#f4dbd6",
    italic = true,
  },
  ["healthError"] = {
    fg = "#ed8796",
  },
  ["healthSuccess"] = {
    fg = "#8bd5ca",
  },
  ["healthWarning"] = {
    fg = "#eed49f",
  },
  ["htmlH1"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5bde6",
  },
  ["htmlH2"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#8aadf4",
  },
  ["illuminatedCurWord"] = {
    bg = "#494d64",
  },
  ["illuminatedWord"] = {
    bg = "#494d64",
  },
  ["lCursor"] = {
    bg = "#f4dbd6",
    fg = "#24273a",
  },
  ["markdownCode"] = {
    fg = "#f0c6c6",
  },
  ["markdownCodeBlock"] = {
    fg = "#f0c6c6",
  },
  ["markdownH1"] = {
    link = "rainbow1",
  },
  ["markdownH2"] = {
    link = "rainbow2",
  },
  ["markdownH3"] = {
    link = "rainbow3",
  },
  ["markdownH4"] = {
    link = "rainbow4",
  },
  ["markdownH5"] = {
    link = "rainbow5",
  },
  ["markdownH6"] = {
    link = "rainbow6",
  },
  ["markdownHeadingDelimiter"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f5a97f",
  },
  ["markdownLinkText"] = {
    cterm = {
      underline = true,
    },
    fg = "#8aadf4",
    underline = true,
  },
  ["mkdCodeDelimiter"] = {
    bg = "#24273a",
    fg = "#cad3f5",
  },
  ["mkdCodeEnd"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f0c6c6",
  },
  ["mkdCodeStart"] = {
    bold = true,
    cterm = {
      bold = true,
    },
    fg = "#f0c6c6",
  },
  ["qfFileName"] = {
    fg = "#8aadf4",
  },
  ["qfLineNr"] = {
    fg = "#eed49f",
  },
  ["rainbow1"] = {
    fg = "#ed8796",
  },
  ["rainbow2"] = {
    fg = "#f5a97f",
  },
  ["rainbow3"] = {
    fg = "#eed49f",
  },
  ["rainbow4"] = {
    fg = "#a6da95",
  },
  ["rainbow5"] = {
    fg = "#7dc4e4",
  },
  ["rainbow6"] = {
    fg = "#b7bdf8",
  },
  ["zshKSHFunction"] = {
    link = "Function",
  },
}

for group, spec in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, spec)
end
