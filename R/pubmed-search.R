# Pubmed search using easypubmed

#Link: https://cran.r-project.org/web/packages/easyPubMed/vignettes/getting_started_with_easyPubMed.html

# Load libraries ---------------------------------------------------------------

library(easyPubMed)
library(tidyverse)
library(here)
library(purrr)
library(readr)
source(here("R/search-terms.R"))

# Search last updated ----------------------------------------------------------

Sys.Date() #2022-11-03

# Search pubmed using the easyPubMed package -----------------------------------

## making a list with the search terms

## search and download pubmed records
pubmed_search <-
    batch_pubmed_download(
        pubmed_query_string = search_terms$pubmed,
        dest_file_prefix = "open_collab_",
        encoding = "UTF-8"
    )

# Extracting info and combining into single dataframe --------------------------

## make a function that convert each XML file to a dataset
make_df_from_pubmed <- function(dataset) {
    new_pubmed_df <- easyPubMed::table_articles_byAuth(
        pubmed_data = dataset,
        included_authors = "first",
        encoding = "UTF-8"
    )
    new_pubmed_df <- tibble::as_tibble(new_pubmed_df)
    return(new_pubmed_df)
}

## use map to single dataframe of all the batches
# !!note: this takes a while!!#
open_collaboration_pubmed_df <-
    map_dfr(pubmed_search, make_df_from_pubmed, .id = NULL)

# Cleaning dataset -------------------------------------------------------------

pubmed_df <- open_collaboration_pubmed_df %>%
    select(lastname, year, title, abstract, jabbrv, email, pmid) %>%
    mutate(database = "pubmed")

# Count number of papers -------------------------------------------------------

# 756 papers identified when copying the search on pubmed

n_papers_web <- 756
n_papers_r <-  as.numeric(nrow(pubmed_df))

search_the_same <- n_papers_web == n_papers_r
search_the_same

# Save dataset -----------------------------------------------------------------

readr::write_csv(pubmed_df, here("data", "pubmed-search.csv.gz"))
