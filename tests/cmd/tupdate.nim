discard """
  cmd: "nim $target --hints:on -d:testing -d:ssl --nimblePath:tests/deps $options $file"

  input: '''
y
-
'''
"""

import json, os
import cli/clr
import cmd/update

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
      "projectID": 238222,
      "fileID": 3383205,
      "required": true,
      "__meta": {
        "name": "Just Enough Items (JEI)",
        "explicit": true,
        "dependencies": []
      }
    }
  ]
}

block: # update mod
  removeDir("./modpack/")

  createDir("./modpack")
  writeFile("./modpack/manifest.json", manifestJson.pretty)
  paxUpdate("jei", strategy = "recommended")

  let manifest = readFile("./modpack/manifest.json").parseJson
  doAssert manifest["files"].getElems().len == 1
  doAssert manifest["files"][0]["fileID"].getInt() > 3383205

  doAssert stdin.readLine() == "-"