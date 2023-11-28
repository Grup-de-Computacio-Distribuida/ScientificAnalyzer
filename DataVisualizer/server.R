source("global.R")
# Define server logic required to draw a histogram
server <- function(input, output) {
  get_n_documents_by_year <- reactive({
    start_year <- as.numeric(input$years[1])
    end_year <- as.numeric(input$years[2])
    datos <- mutate(papers_all, ALL = 1)
    tabla_resumen <- table(datos$year) %>% as.data.frame()
    tabla_resumen$Freq <- as.integer(tabla_resumen$Freq)
    return(tabla_resumen)
  })
  
  get_top10_data <- reactive({
    start_year <- as.numeric(input$years[1])
    end_year <- as.numeric(input$years[2])
    d <- data.frame(rang = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
    for (i in start_year:end_year) {
      aux <- topics(subset(papers_all, year == i)['title'])[, 1]
      if(length(aux) < 10){
        aux <- c(aux, rep("-", 10 - length(aux)))
      }
      d[, paste(i)] <- head(aux, 10)
    }
    d$rang <- as.integer(d$rang)
    d
  })
  
  
  output$resumeTable <- renderTable(striped = TRUE, align = 'c', spacing = 'xs',width = '100%',{
    n_documents_by_year <- get_n_documents_by_year()
    n_documents_by_year <- bind_rows(n_documents_by_year, data.frame(Var1 = "TOTAL", Freq = sum(n_documents_by_year$Freq)))
    n_documents_by_year <- spread(n_documents_by_year, key = Var1, value = Freq)
    n_documents_by_year

  })
  


  
  output$totalByYear <- renderPlot({
    df <- get_n_documents_by_year()
    df$Freq <- as.numeric(df$Freq)
    df$PercentageChange <- c(0, diff(df$Freq) / df$Freq[-length(df$Freq)] * 100)
    
    ggplot(df, aes(x = Var1, y = Freq)) +
      geom_line(aes(group = 1), linetype = "dashed", color = "blue") +
      geom_point(aes(y = Freq), color = "blue", size = 3) +
      geom_text(aes(label = sprintf("%d (%.2f%%)", Freq, PercentageChange)), hjust = -0.1,vjust = 2,
                size = 3, color = "red")  +
      labs(y = "Generated Documents", x = "Year") +
      theme_minimal()

    
    
  })
  
  
  output$top10_table <- renderTable(striped = TRUE,align = 'c', {
    get_top10_data()
  })
  
  
  
  output$top_10_terms <- renderTable(striped = TRUE,colnames = FALSE,align = 'c', spacing = 'xs',width = '100%',{
    start_year <- as.numeric(input$years[1])
    end_year <- as.numeric(input$years[2])
    n_years = end_year - start_year + 1
    
    d <- get_top10_data()
    aux_map <- list()
    for (i in 2:ncol(d)) {
      for (f in 1:nrow(d)) {
        word <- d[f, i]
        if (!(word %in% names(aux_map))) {
          aux_map[[word]] <- 0
        }
      }
    }
    aux_map = names(aux_map)
    aux_map<-aux_map[aux_map != '-']
    aux_map
  })
  
  
  output$top10_plot <- renderPlot({
    start_year <- as.numeric(input$years[1])
    end_year <- as.numeric(input$years[2])
    n_years = end_year - start_year + 1
    
    d <- get_top10_data()
    aux_map <- list()
    for (i in 2:ncol(d)) {
      for (f in 1:nrow(d)) {
        word <- d[f, i]
        if (!(word %in% names(aux_map))) {
          aux_map[[word]] <- c(rep(NA, times = n_years))
        }
        aux_map[[word]][i - 1] <- f
      }
    }
    Word = c()
    Top10 = c()
    for (key in names(aux_map)) {
      for (i in rep(key, times = n_years))
        Word <- c(Word, i)
      for (i in aux_map[[key]])
        Top10 <- c(Top10, i)
    }
    Year <-
      c(rep(start_year:end_year, times = length(names(aux_map))))
    graf <- data.frame(Year = Year,
                       Top10 = Top10,
                       Word = Word)
    top10_plot = ggplot(
      data = graf,
      aes(x = Year, y = Top10, label = Word),
      ylim = c(10, 1),
      show.legend = FALSE
    )  +
      geom_line(aes(colour = Word), size = 0.3)  +
      geom_point(aes(colour = Word)) +
      geom_text(hjust = 0.5,
                vjust = 2,
                size = 2.5) +
      scale_y_continuous(
        name = "Top 10",
        trans = "reverse",
        breaks = c(10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
      ) +
      scale_x_continuous(name = "Year", breaks = c(start_year:end_year)) +
      guides(color = FALSE, size = FALSE) + guides(color = FALSE, size = FALSE) 
    
    #ggsave("top10_graph.png", top10_plot, dpi=300) #Decomment to save on a folder a big plot 
    top10_plot 
    
    
  })
  output$top_3_by_year <- renderTable(striped = TRUE,spacing = 'xs',width = '100%',{
    start_year <- as.numeric(input$years[1])
    end_year <- as.numeric(input$years[2])
    top3_docs <-
      papers_all %>%  group_by(year) %>% top_n(3, citations)
    top3_docs <-
      top3_docs %>% filter(between(year, start_year, end_year))
    df <- top3_docs[order(top3_docs$year, top3_docs$citations), ]
    df <- df[, -ncol(df)]
  })
  
  
  
  
}