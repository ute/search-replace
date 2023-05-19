# Search-replace Extension for Quarto

Quarto filter extension that lets you automatically search and replace strings in quarto document when rendering, in a similar way as simple LaTeX macros.

Define pairs of search string and replacement in the document yaml, and let quarto do the work. The filter searches document text, including link targets. Replacements may include markdown text modifiers (emphasis) and math inline formulae.


## Installing

```bash
quarto add ute/search-replace
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Include the filter in the document's yaml, and add a key `search-replace`. Under this key, define your search-replace pairs as subkeys in the form `search : replace`. It is a good idea to start the search key with a special character, such as "+" or ".", although it is not required.

Upon rendering, every string or sub-string that matches a search key will be replaced in the main text, and in link targets. Search keys should not be contained in each other - this would give ambiguous results.

### Example:
With the yaml
```yaml
---
filters:
  - search-replace
search-replace:
  +quarto: "[Quarto](https://quarto.org)"
  +qurl  : https://quarto.org/docs
  +forml : $\alpha * \beta = \gamma$
  +pyth  : "Pythagoras' theorem: $a^2 + b^2 = \\dots$"
  .doo   : "- doodledoo - "
  +dab   : "**dab**"
  "!doa" : "`duaaah`"
  +br    : <br>\newline
---  
```
document text
```md
+quarto allows us to write beautiful texts 
about +pyth or similar complicated formulas (e.g. +forml), 
and to [create our *own* filters](+qurl/extensions/filters.html). +br
Even extensions that replace text:+br
.doo+dab+dab!doa, +dab!doa!
```
gets rendered as

> [Quarto](https://quarto.org) allows us to write beautiful texts about Pythagoras' theorem: $a^2 + b^2 = \dots$ or similar complicated formulas (e.g. $\alpha *\beta=\gamma$),  
and to [create our *own* filters](https://quarto.org/docs/extensions/filters.html). <br>\newline 
Even extensions that replace text:<br>\newline
- doodledoo -**dab****dab**`duaaah`, **dab**`duaaah`!

## Known quirks

- search keys and replacement strings that can be interpreted as yaml because of special characters such as `:`,  or leading  `-`,`` ` ``,`[`, `!`, have to be enquoted. To be on the safe side, you can just enquote all replacement strings.
- backslashes in LaTeX formulae have to be escaped with a second backslash if and only if the containing string is enquoted.

## Acknowledgement

 [Scott Koga-Browes](https://github.com/scokobro)' lovely python-based pandoc filter [pandoc-abbreviations](https://github.com/scokobro/pandoc-abbreviations) that replaces text strings (not links) inspired me to write this quarto extension. He requires the search keys to start with a "+" sign which gives a nice and clear appearance - they are easy to spot in the source text.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

