discard """
  cmd: "nim $target --hints:on -d:testing -d:ssl --nimblePath:tests/deps $options $file"

  input: '''
y
-
y
-
y
-
y
-
  '''
"""

import json, os
import cli/clr
import cmd/remove

terminalColorEnabledSetting = false

let manifestJson = %* {
  "minecraft": {
    "version": "1.16.5",
    "modLoaders": [
      {
        "id": "forge-36.1.0",
        "primary": true
      }
    ]
  },
  "manifestType": "minecraftModpack",
  "overrides": "overrides",
  "manifestVersion": 1,
  "version": "1.0.0",
  "author": "testauthor",
  "name": "testmodpack123",
  "files": [
    {
      "projectID": 60089,
      "fileID": 3202662,
      "required": true,
      "__meta": {
        "name": "Mouse Tweaks",
        "explicit": true,
        "dependencies": []
      }
    },
    {
      "projectID": 238222,
      "fileID": 3383205,
      "required": true,
      "__meta": {
        "name": "Just Enough Items (JEI)",
        "explicit": true,
        "dependencies": []
      }
    },
    {
      "projectID": 240630,
      "fileID": 3336760,
      "required": true,
      "__meta": {
        "name": "Just Enough Resources (JER)",
        "explicit": true,
        "dependencies": [
          238222
        ]
      }
    },
    {
      "projectID": 243121,
      "fileID": 3366626,
      "required": true,
      "__meta": {
        "name": "Quark",
        "explicit": true,
        "dependencies": [
          250363
        ]
      }
    },
    {
      "projectID": 250363,
      "fileID": 3326041,
      "required": true,
      "__meta": {
        "name": "AutoRegLib",
        "explicit": false,
        "dependencies": []
      }
    }
  ]
}

block: # remove mod without dependencies
  removeDir("./modpack/")

  createDir("./modpack")
  writeFile("./modpack/manifest.json", manifestJson.pretty)
  paxRemove("mouse", strategy = "recommended")

  let manifest = readFile("./modpack/manifest.json").parseJson
  doAssert manifest["files"].getElems().len == 4
  doAssert manifest["files"][0]["__meta"]["name"].getStr() == "Just Enough Items (JEI)"
  doAssert manifest["files"][1]["__meta"]["name"].getStr() == "Just Enough Resources (JER)"
  doAssert manifest["files"][2]["__meta"]["name"].getStr() == "Quark"
  doAssert manifest["files"][3]["__meta"]["name"].getStr() == "AutoRegLib"

  doAssert stdin.readLine() == "-"

block: # remove mod with dependency
  removeDir("./modpack/")

  createDir("./modpack")
  writeFile("./modpack/manifest.json", manifestJson.pretty)
  paxRemove("quark", strategy = "recommended")

  let manifest = readFile("./modpack/manifest.json").parseJson
  doAssert manifest["files"].getElems().len == 3
  doAssert manifest["files"][0]["__meta"]["name"].getStr() == "Mouse Tweaks"
  doAssert manifest["files"][1]["__meta"]["name"].getStr() == "Just Enough Items (JEI)"
  doAssert manifest["files"][2]["__meta"]["name"].getStr() == "Just Enough Resources (JER)"

  doAssert stdin.readLine() == "-"

block: # remove mod with explicitly installed dependency
  removeDir("./modpack/")

  createDir("./modpack")
  writeFile("./modpack/manifest.json", manifestJson.pretty)
  paxRemove("jer", strategy = "recommended")

  let manifest = readFile("./modpack/manifest.json").parseJson
  doAssert manifest["files"].getElems().len == 4
  doAssert manifest["files"][0]["__meta"]["name"].getStr() == "Mouse Tweaks"
  doAssert manifest["files"][1]["__meta"]["name"].getStr() == "Just Enough Items (JEI)"
  doAssert manifest["files"][2]["__meta"]["name"].getStr() == "Quark"
  doAssert manifest["files"][3]["__meta"]["name"].getStr() == "AutoRegLib"

  doAssert stdin.readLine() == "-"

block: # try removing mod that is a dependency
  removeDir("./modpack/")

  createDir("./modpack")
  writeFile("./modpack/manifest.json", manifestJson.pretty)
  paxRemove("jei", strategy = "recommended")

  let manifest = readFile("./modpack/manifest.json").parseJson
  doAssert manifest["files"].getElems().len == 5
  doAssert manifest["files"][0]["__meta"]["name"].getStr() == "Mouse Tweaks"
  doAssert manifest["files"][1]["__meta"]["name"].getStr() == "Just Enough Items (JEI)"
  doAssert manifest["files"][2]["__meta"]["name"].getStr() == "Just Enough Resources (JER)"
  doAssert manifest["files"][3]["__meta"]["name"].getStr() == "Quark"
  doAssert manifest["files"][4]["__meta"]["name"].getStr() == "AutoRegLib"

  doAssert stdin.readLine() == "-"