# Background

- <b>Goal: </b>How to offer customers accurate movie recommendations based on a customers's own perferences and viewing history?

- <b>Data: </b>
  - movie's ranking from all users in the database
  - facts about the movies: actors, directors, genre classifications, year released, etc

- <b>Statistical Techiniques:</b>
  - Collaborative Filtering: only uses other similar user's ratings to make predictions
    - Technique: Clustering
    - Pros: can accuartely suggest complex items without understanding the nature of the items
    - Cons: requires a lot of data about the user to make accurate recommendations 

  - Content Filtering: only uses the information about the movies that users saw before. Not other users inloved 
    - Pros: requires very little data to get started
    - Cons: can be limited in scope (can only recommend similar things to what the user has already liked)
    
  - Hybrid Recommendation System: uses collaborative and content filtering. <br>
For example, first use collaborative filtering approach to determine the similar preferces users group, then do content filtering to find movies that the users group all like, and recommend similar classification movies to the group users. 

# Clustering 
#### <b> Pre-Analysis:</b>
- Categories: Movies are categorized as belonging to different genres, each movie may belong to many genres
 - Action, Adventure, Animation, Children's, Comedy, Crime, Documentary, Drama, Fantasy, Film Noir, Horror, Musical, Mystery, Romance, Sci-FI, Thriller, War, Western, (Unknown)
- <b> Raised Question 1 : Is it possible to systematically find groups of movies with similar sets of genres?</b>
  - Answer: Clustering. 
  
#### Goal:
- To segment the data into similar groups
- Not to make predictions, but clustering the data into "similar" groups can improve the predictive methods when building models for each "simliar" group
