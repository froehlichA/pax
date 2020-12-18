import algorithm, asyncdispatch, asyncfutures, sequtils, json
import ../lib/io/files, ../lib/io/http, ../lib/io/io, ../lib/io/term
import ../lib/obj/manifest, ../lib/obj/mods, ../lib/obj/modutils

proc cmdList*(): void =
  ## list installed mods & their current versions
  requirePaxProject

  echoDebug "Loading files from manifest.."
  let manifestJson = parseJson(readFile(manifestFile))
  let project = projectFromJson(manifestJson)
  let fileCount = project.files.len
  let allModRequests = project.files.map(proc(file: ManifestFile): Future[McMod] {.async.} =
    return (await asyncFetch(modUrl(file.projectId))).parseJson.modFromJson
  )
  let allModFileRequests = project.files.map(proc(file: ManifestFile): Future[McModFile] {.async.} =
    return (await asyncFetch(modFileUrl(file.projectId, file.fileId))).parseJson.modFileFromJson
  )
  let mods = all(allModRequests)
  let modFiles = all(allModFileRequests)

  echoInfo "Loading mods.."
  waitFor(mods and modFiles)
  var modData = zip(mods.read(), modFiles.read())
  modData = modData.sorted(proc (x, y: (McMod, McModFile)): int = cmp(x[0].name, y[0].name))
  echoRoot "ALL MODS ".clrMagenta, ("(" & $fileCount & ")").clrGray
  for index, content in modData:
    let mcMod = content[0]
    let mcModFile = content[1]
    let fileUrl = mcMod.websiteUrl & "/files/" & $mcModFile.fileId
    let fileCompabilityIcon = mcModFile.getFileCompability(project.mcVersion).getIcon()
    let fileFreshnessIcon = mcModFile.getFileFreshness(project.mcVersion, mcMod).getIcon()
    echo promptPrefix, fileCompabilityIcon, fileFreshnessIcon, " ", mcMod.name, " ", fileUrl.clrGray
  if fileCount == 0:
    echo promptPrefix, "No mods installed yet.".clrGray