baseUrl <- Sys.getenv("BaseUrl")
ROhdsiWebApi::authorizeWebApi(baseUrl = baseUrl, authMethod = "windows")

cohortIdsToExport <-
  ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl)

evansCohorts <- cohortIdsToExport |>
  dplyr::filter(stringr::str_detect(
    string = name,
    pattern = stringr::fixed("[PhePheb] HIE")
  ))

evansCohortDefinitionSet <-
  ROhdsiWebApi::exportCohortDefinitionSet(baseUrl = baseUrl,
                                          cohortIds = evansCohorts$id,
                                          generateStats = TRUE)


baseUrlAtlasDemo <- "https://api.ohdsi.org/WebAPI"

postedCohortDefinitions <- c()
for (i in (1:nrow(evansCohortDefinitionSet))) {
  postedCohortDefinitions[[i]] <- ROhdsiWebApi::postCohortDefinition(
    name = evansCohortDefinitionSet[i,]$cohortName,
    cohortDefinition = evansCohortDefinitionSet[i,]$json |> RJSONIO::fromJSON(digits = 23),
    baseUrl = baseUrlAtlasDemo
  )
}

postedCohortDefinitions <- dplyr::bind_rows(postedCohortDefinitions)


postedCohortDefinitions |> 
  dplyr::select(id, name) |> 
  clipr::write_clip()
