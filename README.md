# Search-replace Extension for Quarto

Quarto filter extension that lets you automatically search and replace strings in quarto document when rendering, in a similar way as simple LaTeX text macros.

Define pairs of search string and replacement in the document yaml, and let quarto do the work. The filter searches document text, including link targets. Replacements may include markdown text modifiers (emphasis) and math inline formulae.

#### News:
**Format dependent** replacements are currently possible for pdf and html. Send a PR or open an issue if you need further formats :-)


## Installing

```bash
quarto add ute/search-replace
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Include the filter in the document's yaml, and add a key `search-replace`. Under this key, define your search-replace pairs as subkeys in the form `search : replace`. It is a good idea to start the search key with a special character, such as "+" or ".", although it is not required.

Upon rendering, every string or sub-string that matches a search key will be replaced in the main text, and in link targets. Search keys should not be contained in each other - this would give ambiguous results.

For format dependent rendering, two keys are reserved: **`--pdf--`** and **`--html--`** (further may be added upon request). List format specific abbreviations here.

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
  +pyth  : "*Pythagoras' theorem*: $a^2 + b^2 = \\dots$"
  .doo   : "- doodledoo - "
  +dab   : "**dab**"
  "!doa" : "`duaaah`"
  --pdf--:
    +br    : \newline
    +form  : pdf
    +wedo  : "print on paper"
  --html--:
    +br    :  <br>
    +form  : html
    +wedo  : "read on screen"  
---  
```
document text
```text
+quarto allows us to write beautiful texts 
about +pyth or similar complicated formulas (e.g. +forml), 
and to [create our *own* filters](+qurl/extensions/filters.html). +br
Even filters that replace text:+br
.doo+dab+dab+dab!doa, +dab!doa!

Since we wanted to +wedo, we chose to render as +form.
```
gets rendered, if pdf, as

> [Quarto](https://quarto.org) allows us to write beautiful texts about *Pythagoras' theorem*: $a^2 + b^2 = \dots$ or similar complicated formulas (e.g. $\alpha * \beta = \gamma$), and to [create our *own* filters](https://quarto.org/docs/extensions/filters.html). <br> 
Even filters that replace text:<br>
\- doodledoo -**dabdabdab**`duaaah`, **dab**`duaaah`!
> 
> Since we wanted to read on paper, we chose to render as pdf.

## Known quirks

- search keys and replacement strings that can be interpreted as yaml because of special characters such as `:`,  or leading  `-`,`` ` ``,`[`, `!`, have to be enquoted. To be on the safe side, you can just enquote all replacement strings.
- backslashes in LaTeX formulae have to be escaped with a second backslash if and only if the containing string is enquoted.

## Acknowledgement

 [Scott Koga-Browes](https://github.com/scokobro)' lovely python-based pandoc filter [pandoc-abbreviations](https://github.com/scokobro/pandoc-abbreviations) that replaces text strings (not links) inspired me to write this quarto extension. He requires the search keys to start with a "+" sign which gives a nice and clear appearance - they are easy to spot in the source text.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

