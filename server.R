

server <- function(input, output,  session) {
  
  source(file = "sections/server_national.R", local = T)
  source(file = "sections/server_admin.R", local = T)
  source(file = "sections/server_insitu.R", local = T)
  source(file = "sections/server_social.R", local = T)
  
}
