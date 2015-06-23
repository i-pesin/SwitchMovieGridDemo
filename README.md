# SwitchMovieGridDemo

Minor task overview:

The Requirement is as follows:

"Your app should display a grid of 15 thumbnails (displayed at 100 x 100 points), after scrolling to the bottom of the current list, you should load another 15 into the collection view."

IMHO it's not a very good approach: if the connection is low or some images are not available it will make User wait certain amount of time. Moreover when User scrolls to the bottom he doesn't necessarily want to see all 15 new images, maybe 1 new row is enough. 
So I suggest the following:

1. Download an image only for rows that are already visible on the screen. 
2. Display a downloaded image immediately (do not wait for other 14).
3. Initially start to download 15 (28 for iPhone 6+) images (they are all visible on the screen). When User scrolls to the bottom, perform the following check: if at least one image is downloaded, allow User to download the next 15 images (but start downloading for any row only when User scrolls down to it). If no images are downloaded wait until they are. After that each time when User scrolls to the bottom check if at least 15 images were downloaded after the previous check.