import strutils, json
import ../lib/flow
import ../lib/io/cli, ../lib/io/files, ../lib/io/http, ../lib/io/io, ../lib/io/term
import ../lib/obj/manifest

proc cmdInit*(force = false): void =
  ## initialize a new modpack in the current directory
  if not force:
    rejectPaxProject
    returnIfNot promptYN("Are you sure you want to create a pax project in the current folder?", default=true)

  echoInfo "Updating databases.."
  let forgeVersionJson = parseJson(fetch(forgeVersionUrl))

  echoRoot "MANIFEST".clrGray
  var project = ManifestProject()
  project.name = prompt(promptPrefix & "Modpack name")
  project.author = prompt(promptPrefix & "Modpack author")
  project.version = prompt(promptPrefix & "Modpack version", default="1.0.0")
  project.mcVersion = prompt(promptPrefix & "Minecraft version", default="1.16.4")
  
  let recommendedForgeVersion = forgeVersionJson{"by_mcversion", project.mcVersion, "recommended"}.getStr()
  let latestForgeVersion = forgeVersionJson{"by_mcversion", project.mcVersion, "latest"}.getStr()
  let forgeVersion = if recommendedForgeVersion != "": recommendedForgeVersion else: latestForgeVersion
  if forgeVersion == "":
    echoError "This is either not a minecraft version, or no forge version exists for this minecraft version."
    return
  let manifestForgeVersion = "forge-" & forgeVersion.split("-")[1]
  project.mcModloaderId = manifestForgeVersion
  echoDebug "Recommended Forge version is ", project.mcModloaderId

  echoInfo "Creating manifest.."
  createDirIfNotExists(packFolder)
  createDirIfNotExists(overridesFolder)
  writeFile(manifestFile, project.toJson.pretty)