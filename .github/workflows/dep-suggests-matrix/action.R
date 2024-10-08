# FIXME: Dynamic lookup by parsing https://svn.r-project.org/R/tags/
get_deps <- function() {
  # Determine package dependencies
  if (!requireNamespace("desc", quietly = TRUE)) {
    install.packages("desc")
  }

  deps_df <- desc::desc_get_deps()
  deps_df_optional <- deps_df$package[deps_df$type %in% c("Suggests", "Enhances")]
  deps_df_hard <- deps_df$package[deps_df$type %in% c("Depends", "Imports", "LinkingTo")]
  deps_df_base <- unlist(tools::standard_package_names(), use.names = FALSE)

  packages <- sort(deps_df_optional)
  packages <- intersect(packages, rownames(available.packages()))

  # Too big to fail, or can't be avoided:
  off_limits <- c("testthat", "rmarkdown", "rcmdcheck", deps_df_hard, deps_df_base)
  off_limits_dep <- unlist(tools::package_dependencies(off_limits, recursive = TRUE, which = "strong"))
  setdiff(packages, c(off_limits, off_limits_dep))
}

packages <- get_deps()

if (length(packages) > 0) {
  json <- paste0(
    '{"package":[',
    paste0('"', packages, '"', collapse = ","),
    ']}'
  )
} else {
  json <- character()
}

writeLines(json, ".github/dep-suggests-matrix.json")
writeLines(json)
