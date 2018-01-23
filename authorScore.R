library(RMySQL)
library(dplyr)

#connect to db
my_db <- dbConnect(MySQL(), user='root', password='root', dbname='pubmed', host='localhost') 
dbListTables(my_db)
rs <- dbSendQuery(my_db, 'select * from authors')

#load data from sql
data <- fetch(rs, n=-1)
pmid_vec <- as.numeric(data$pmid)
count_freq <- as.data.frame(table(pmid_vec), stringsAsFactors = F)
counter <- 0

#calculate contribution score for each author
for(i in 1:nrow(data))
{
  
  pub_id <- data$pmid[i]
  
  counter <- counter + 1
  if(counter == 1)
  {
    data$author_score[i] <- 1
    
  }
  else if(counter == 2)
  {
    
    data$author_score[i] <- 0.5
    
  }
  else
  {
    temp <- count_freq %>% filter(pmid_vec == pub_id)
    data$author_score[i] <- 0.5 / (temp[,2] - 2)
    
  }
  if(i < nrow(data))
  {
    if(pub_id != data$pmid[i+1])
    { 
      counter <- 0  
    }
  }
}  
  #watch for overwrite
dbWriteTable(my_db,'authors', data, overwrite=T )
head(data)
