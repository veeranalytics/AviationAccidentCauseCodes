# Step 01: Load libraries and data
library(tm)
library(dplyr)
library(stringr)
library(tidyr)
library(factoextra)
library(ggplot2)
library(wordcloud)

### Read file
raw <- read.csv('./Airplane_Crashes_and_Fatalities_Since_1908.csv', 
                stringsAsFactors = FALSE)

### Step 02: Some initial formatting and cleaning
crashes <-
  raw %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y")) %>%
  rename(Flight = `Flight..`)

### Load text as corpus
rawtxt <- VCorpus(VectorSource(crashes$Summary))

### Cleaning
rawtxt <- tm_map(rawtxt, removePunctuation)
rawtxt <- tm_map(rawtxt, content_transformer(tolower))
rawtxt <- tm_map(rawtxt, removeWords, stopwords("english"))
rawtxt <- tm_map(rawtxt, stripWhitespace)

# Create document-terms matrix, removing generic terms 
# related to airline industry
stopwrd <- c("killed", "due", "resulted", "cause", "caused", "one", "two",
             "aircraft", "plane", "crashed", "crash", "flight", "flew") 
dtm <- DocumentTermMatrix(rawtxt, control = list(stopwords = stopwrd))
# View document matrix
dtm

### Remove sparse terms from DTM
dtms <- removeSparseTerms(dtm, 0.95)

#Step 03: Find clusters of words
### Compute distance matrix
d <- dist(t(dtms), method = "euclidian")

### Compute K-means
km <- kmeans(d, 10, iter.max = 50, nstart = 10)

### Display results as a list
grouplist = function(input) {
  output <- list()
  for (i in 1:max(input)) {
    output[[i]] <- names(input[input == i]) 
  }
  for (i in output) {
    cat('* ')
    cat(i, sep = ", ")
    cat("\n")
  }
}

grouplist(km$cluster)

# By plotting the clusters using the factoextra package. The axes will 
# show us how far clusters are from each others.
fviz_cluster(km, data = d, geom = "text", show.clust.cent = FALSE, repel = TRUE, labelsize = 3) +
  theme(legend.position = "none") +
  labs(title = "", x = "", y = "")

### Step 04: Association with most frequent terms
# begin by plotting the 20 most frequent terms. All of them are obviously 
# included in the above cluster analysis, but here we get a sense of their 
# frequency relatively to each others.

### Order terms by frequency
freq <- colSums(as.matrix(dtm))
freq <- 
  freq %>%
  data.frame(term = names(freq), frequency = freq) %>%
  select(term, frequency) %>%
  arrange(desc(frequency)) 

# Word Cloud Map
set.seed(1234)
wordcloud(words = freq$term, freq = freq$frequency, min.freq = 10,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

### Plot most frequent terms
ggplot(freq[1:20, ], aes(x = frequency, y = reorder(term, frequency))) + 
  geom_point(colour = "#2b83ba") + 
  geom_segment(aes(xend = 0, yend = term), size = 1, colour = "#2b83ba") +
  geom_text(aes(label = term, vjust = "middle", hjust = "left"), nudge_x = 10, size = 3.5) +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_line(colour = "#f7f7f7"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.text.y = element_blank(), 
        axis.title = element_blank(), 
        axis.ticks.y = element_blank()) +
  labs(title = "Occurences of top 20 most frequent terms")

# To add more context to the list, we have to look at which terms are most 
# correlated with these 20 frequent terms. For each of them, let's 
# plot the top 5 terms that have a correlation higher than 0.17.
### Terms correlation
assocs <- findAssocs(dtm, as.character(freq[1:20, 1]), corlimit = 0.17)
print(assocs)