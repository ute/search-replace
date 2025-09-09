# Search-replace Extension for Quarto

Quarto filter extension that lets you automatically search and replace strings in quarto document when rendering, in a similar way as simple LaTeX text macros.

Define pairs of search string and replacement in the document yaml, and let quarto do the work. The filter searches document text, including link targets. Replacements may include markdown text modifiers (emphasis) and math inline formulae.

#### News:

- **Format dependent** replacements are possible now for all formats that are detectable by quarto extensions, notably pdf and html, see the [quarto documentation](https://quarto.org/docs/extensions/lua-api.html#format-detection)

- For long lists of replacements, check out extension [`mergemeta`](https://github.com/ute/mergemeta), which allows you to merge in data stored under a different key (not `search-replace`) in another `yaml` file, see under Section [Tip](#tip-pre-defined-abbreviations-in-separate-files)

## Installing

```bash
quarto add ute/search-replace
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Include the filter in the document's yaml, and add a key `search-replace`. Under this key, define your search-replace pairs as subkeys in the form `search : replace`. It is a good idea to start the search key with a special character, such as "+" or ".", although it is not required.

Upon rendering, every string or sub-string that matches a search key will be replaced in the main text, and in link targets. Search keys should not be contained in each other - this would give ambiguous results.

There are some reserved keys (currently only one, but more may be added) that start with '--':

- '--when-format--' is used to specify abbreviations that are only rendered when the document format matches the following sub-key.

### Example:
With the yaml
```yaml
---
format: html
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
  --when-format--:
    html:
      +br    :  <br>
      +form  : html
      +wewant: "read on screen"  
    pdf:  
      +br    : \newline
      +form  : pdf
      +wewant: "print on paper"  
  +dab   : "**dab**"
  "!dua" : "`duaaah`"
---  
```
document text
```text
+quarto allows us to write beautiful texts 
about +pyth or similar complicated formulas (e.g. +forml), 
and to [create our *own* filters](+qurl/extensions/filters.html). +br
Even filters that replace text:+br
.doo+dab+dab+dab!doa, +dab!doa!

Since we wanted to +wewant, we chose to render as +form.
```
gets rendered, if html, as

> [Quarto](https://quarto.org) allows us to write beautiful texts about *Pythagoras' theorem*: $a^2 + b^2 = \dots$ or similar complicated formulas (e.g. $\alpha * \beta = \gamma$), and to [create our *own* filters](https://quarto.org/docs/extensions/filters.html). <br> 
Even filters that replace text:<br>
\- doodledoo -**dabdabdab**`duaaah`, **dab**`duaaah`!
> 
> Since we wanted to read on screen, we chose to render as html.

## Known quirks

- search keys and replacement strings that can be interpreted as yaml because of special characters such as `:`,  or leading  `-`,`` ` ``,`[`, `!`, have to be enquoted. To be on the safe side, you can just enquote all replacement strings.
- backslashes in LaTeX formulae have to be escaped with a second backslash if and only if the containing string is enquoted.


## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

## Tip: pre-defined abbreviations in separate files 

Store long lists of search-replace items in an extra yaml file and include it in the documents yaml using the `metadata-files` key.
With the [`mergemeta`](https://github.com/ute/mergemeta) extension, the abbreviations can be merged into the `search-replace` key. This avoids overwriting document specific abbreviations, and allows to combine multiple abbreviation sources files.

For example, file [`myabbreviations.yml`](myabbreviations.yml) contains search-replace definitions stored under `mystuff`:

```yml
mystuff:
  +quarto: "[Quarto](https://quarto.org)"
  +qurl  : https://quarto.org/docs
# etc  
```
 and can be used in qmd document [`mergemeta-example.qmd`](mergemeta-example.qmd) with the yaml header
 
```yml
---
format: html
filters:
  - mergemeta
  - search-replace
metadata-files: 
  - myabbreviations.yml # defines mystuff

mergemeta:
   search-replace: mystuff
---  
```

Make sure to list filter `mergemeta` before `search-replace`.

## Acknowledgement

 [Scott Koga-Browes](https://github.com/scokobro)' lovely python-based pandoc filter [pandoc-abbreviations](https://github.com/scokobro/pandoc-abbreviations) that replaces text strings (not links) inspired me to write this quarto extension. He requires the search keys to start with a "+" sign which gives a nice and clear appearance - they are easy to spot in the source text.
