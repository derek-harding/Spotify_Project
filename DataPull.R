library(httr)
library(tidyr)
library(dplyr)
library(purrr)

clientID = 'fc1431c1d2b14344a39ad397695f098b'
secret = '979fe2f89cdb4b85bfe31dc9703e0faa'

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

URI = paste0('https://api.spotify.com/v1/users/dhvols1/playlists/18WUBxYcdwXN0dMiRdeUW6/tracks?limit=100')
response2 <- GET(url = URI, add_headers(Authorization = HeaderValue))
Tracks <- content(response2)

Tracks2 <- Tracks$items

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

offset <- nrow(Tracks2_df)
HeaderValue <- paste0('Bearer ', mytoken)
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