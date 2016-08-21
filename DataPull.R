library(httr)
library(tidyr)
library(dplyr)
library(purrr)

# Client and Secret ID's Keep Secret actually secret!
clientID = 'fc1431c1d2b14344a39ad397695f098b'
secret = '979fe2f89cdb4b85bfe31dc9703e0faa'

# Token Stuff
response = POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(clientID, secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

mytoken = content(response)$access_token

HeaderValue <- paste0('Bearer ', mytoken)


#Pull Playlist tracks from API
URI = paste0('https://api.spotify.com/v1/users/dhvols1/playlists/18WUBxYcdwXN0dMiRdeUW6/tracks?limit=100')
response2 <- GET(url = URI, add_headers(Authorization = HeaderValue))
Tracks <- content(response2)

Tracks2 <- Tracks$items

#Put tracks into a data frame 
Tracks2_df <- data.frame()
for(i in 1:length(Tracks2)){
  Tracks_df <- data.frame(added_at = as.character(Tracks2[[i]]$added_at),
                          arist_id = as.character(Tracks2[[i]]$track$artists[[1]]$id),
                          artist_name = as.character(Tracks2[[i]]$track$artists[[1]]$name),
                          album_name = as.character(Tracks2[[i]]$track$album$name),
                          track_duration_ms = as.numeric(Tracks2[[i]]$track$duration_ms),
                          track_explicit_flag = as.logical(Tracks2[[i]]$track$explicit),
                          track_id = as.character(Tracks2[[i]]$track$id),
                          track_name = as.character(Tracks2[[i]]$track$name),
                          track_popularity = as.numeric(Tracks2[[i]]$track$popularity),
                          album_image = as.character(Tracks2[[i]]$track$album$images[[1]]$url),
                          track_preview = ifelse(is.null(as.character(Tracks2[[i]]$track$preview_url)),
                                                         NA,as.character(Tracks2[[i]]$track$preview_url)))
  Tracks2_df <- Tracks2_df %>% bind_rows(Tracks_df)
  print(i)
  }


# There is a limit of 100 tracks per call. This pulls the rest of the tracks
offset <- nrow(Tracks2_df)
URI = paste0('https://api.spotify.com/v1/users/dhvols1/playlists/18WUBxYcdwXN0dMiRdeUW6/tracks?offset=',offset)
response2 <- GET(url = URI, add_headers(Authorization = HeaderValue))
Tracks <- content(response2)

Tracks2 <- Tracks$items

for(i in 1:length(Tracks2)){
  Tracks_df <- data.frame(added_at = as.character(Tracks2[[i]]$added_at),
                          arist_id = as.character(Tracks2[[i]]$track$artists[[1]]$id),
                          artist_name = as.character(Tracks2[[i]]$track$artists[[1]]$name),
                          album_name = as.character(Tracks2[[i]]$track$album$name),
                          track_duration_ms = as.numeric(Tracks2[[i]]$track$duration_ms),
                          track_explicit_flag = as.logical(Tracks2[[i]]$track$explicit),
                          track_id = as.character(Tracks2[[i]]$track$id),
                          track_name = as.character(Tracks2[[i]]$track$name),
                          track_popularity = as.numeric(Tracks2[[i]]$track$popularity),
                          album_image = as.character(Tracks2[[i]]$track$album$images[[1]]$url),
                          track_preview = ifelse(is.null(as.character(Tracks2[[i]]$track$preview_url)),
                                                 NA,as.character(Tracks2[[i]]$track$preview_url)))
  Tracks2_df <- Tracks2_df %>% bind_rows(Tracks_df)
  print(i)
}

Audio_Features_df2 <- data.frame()
for(i in 1:nrow(Tracks2_df)){
  
  URI = paste0('https://api.spotify.com/v1/audio-features?ids=',Tracks2_df$track_id[i])
  response2 <- GET(url = URI, add_headers(Authorization = HeaderValue))
  Audio_Features <- content(response2)
  
  Audio_Features_df <- data.frame(id = Audio_Features$audio_features[[1]]$id,
                                  danceability = Audio_Features$audio_features[[1]]$danceability,
                                  energy = Audio_Features$audio_features[[1]]$energy,
                                  loudness = Audio_Features$audio_features[[1]]$loudness,
                                  mode = Audio_Features$audio_features[[1]]$mode,
                                  speechiness = Audio_Features$audio_features[[1]]$speechiness,
                                  acousticness = Audio_Features$audio_features[[1]]$acousticness,
                                  instrumentalness = Audio_Features$audio_features[[1]]$instrumentalness,
                                  liveness = Audio_Features$audio_features[[1]]$liveness,
                                  valence = Audio_Features$audio_features[[1]]$valence,
                                  temp = Audio_Features$audio_features[[1]]$tempo,
                                  time_signature = Audio_Features$audio_features[[1]]$time_signature)
  Audio_Features_df2 <- Audio_Features_df2 %>%
    bind_rows(Audio_Features_df)
  print(i)
}

Full_Track_Data <- Tracks2_df %>%
  left_join(Audio_Features_df2, by = c("track_id" = "id"))