

translate_sql_to_bigquery_fixed <- function(sql){

  sql_bq <- SqlRender::translate(paste(testSql, collapse = "\n"), "bigquery")

  sql_bq <- sql_bq |> stringr::str_replace_all("\\[index\\]", "`index`")

  return(sql_bq)
}

