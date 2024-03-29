discard """
  cmd: "nim $target --hints:on -d:testing -d:ssl --nimblePath:tests/deps $options $file"
"""

import asyncdispatch, sequtils, sugar
import api/cf

block: # fetch by query
  let mods = waitFor(fetchModsByQuery("jei"))
  doAssert mods[0].projectId == 238222
  doAssert mods[0].name == "Just Enough Items (JEI)"

block: # fetch mod by id
  let mcMod = waitFor(fetchMod(220318))
  doAssert mcMod.projectId == 220318
  doAssert mcMod.name == "Biomes O' Plenty"

block: # fetch mod by slug
  var mcMod = waitFor(fetchMod("appleskin"))
  doAssert mcMod.projectId == 248787
  mcMod = waitFor(fetchMod("dtbop"))
  doAssert mcMod.projectId == 289529
  mcMod = waitFor(fetchMod("dtphc"))
  doAssert mcMod.projectId == 307560

block: # fetch mod files
  let modFiles = waitFor(fetchModFiles(248787))
  doAssert modFiles.any((x) => x.fileId == 3035787)

block: # fetch mod file
  let modFile = waitFor(fetchModFile(306770, 2992184))
  doAssert modFile.fileId == 2992184
  doAssert modFile.name == "Patchouli-1.0-21.jar"

block: # Check if dependencies install
  let modFile = waitFor(fetchModFile(243121, 3366626))
  doAssert modFile.dependencies == @[250363]
