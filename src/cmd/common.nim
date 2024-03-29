import algorithm, sequtils, strutils, sugar, options
import ../cli/clr, ../cli/prompt, ../cli/term
import ../modpack/manifest, ../modpack/mods

proc echoMod*(mcMod: McMod, prefix: TermOut = "", postfix: TermOut = "", url: TermOut = mcMod.websiteUrl.dim, moreInfo: bool = false): void =
  ## output a single `mcMod`.
  ## `prefix` and `postfix` is displayed before and after the mod name respectively.
  ## if `moreInfo` is true, description and downloads will be printed as well.
  var modname = mcMod.name
  var prefixIndent = 0
  if prefix.strLen != 0:
    modname = " " & modname
    prefixIndent = prefix.strLen + 1
  if postfix.strLen != 0:
    modname = modname & " "

  echoClr indentPrefix, prefix, modname, postfix, " - ", url
  if moreInfo:
    echoClr indentPrefix.indent(3 + prefixIndent), "Description: ".cyanFg, mcMod.description
    echoClr indentPrefix.indent(3 + prefixIndent), "Downloads: ".cyanFg, mcMod.downloads.`$`.insertSep('.')

proc promptModChoice*(manifest: Manifest, mcMods: seq[McMod], selectInstalled: bool = false): Option[McMod] =
  ## prompt the user for a choice between `mcMods`.
  ## if `selectInstalled` is true, only installed mods may be selected, otherwise installed mods may not be selected.
  var mcMods = mcMods.reversed
  if selectInstalled:
    mcMods.keepIf((x) => manifest.isInstalled(x.projectId))
    if manifest.files.len == 0:
      return none[McMod]()
  if mcMods.len == 0:
    return none[McMod]()
  if mcMods.len == 1:
    return some(mcMods[0])

  var availableIndexes = newSeq[int]()
  
  echoRoot "RESULTS".dim
  for index, mcMod in mcMods:
    let isInstalled = manifest.isInstalled(mcMod.projectId)
    let isSelectable = selectInstalled == isInstalled
    let selectIndex = mcMods.len - index
    if isSelectable:
      availableIndexes.add(selectIndex)

    let prefix: string =
      if isSelectable: ("[" & $selectIndex & "]").align(4)
      else: "    "
    let postfix: string =
      if isInstalled: "[installed]"
      else: ""

    echoMod(mcMod, prefix.cyanFg, postfix.magentaFg)

  let selectedIndex = prompt("Select a mod", choices = availableIndexes.map((x) => $x), choiceFormat = "1 - " & $mcMods.len).parseInt
  return some(mcMods[mcMods.len - selectedIndex])