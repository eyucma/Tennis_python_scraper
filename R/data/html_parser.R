html_parser <- function(link,dir){
  txt<- read_html(link) %>% toString()
  files <- str_extract_all(txt, '\\w+?\\.csv')[[1]] %>% unique() %>% sort()
  file.path(dir, files)
}

prefixer <- function(files){
  
}