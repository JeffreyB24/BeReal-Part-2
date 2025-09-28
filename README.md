# Project 3 - BeReal-Part-2

Submitted by: Jeffrey Berdeal

BeReal-Part-2 is an app that I continued to further work on. Before the app would just allow new to upload photos to share with friends, but now it includes even more features to the app. 

Time spent: 72 hours spent in total

## Required Features

The following **required** functionality is completed:

- [X] User can launch camera to take photo instead of photo library
- [X] Users without iPhones to demo this feature can manually add unique photos to their simulator's Photos app
- [X] Users are not able to see other users’ photos until they upload their own.
- [X] Users can intereact with posts via comments, comments will have user data such as username and name
- [X] Posts have a time and location attached to them
- [X] Users are not able to see other photos until they post their own (within 24 hours)	
 
The following **optional** features are implemented:

- [X] User receive notifcation when it is time to post

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

## Video Walkthrough

<div>
    <a href="https://www.loom.com/share/af78cfe4732241d8bca269a857c48d50">
    </a>
    <a href="https://www.loom.com/share/af78cfe4732241d8bca269a857c48d50">
      <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/af78cfe4732241d8bca269a857c48d50-b68aebf91a660808-full-play.gif">
    </a>
  </div>

## Notes

- I had trouble integrating the camera and photo picker into one flow without breaking the image preview.
- I ran into issues with missing Info.plist permissions that caused the camera, location, or photos not to work.
- Setting up a new phone for testing was confusing because of Developer Mode, device trust, and provisioning profiles.
- Camera photos didn’t include GPS data, so posts were saved without locations until I added a one-shot location manager.
- Reverse geocoding was tricky since it needed caching and cancellation to avoid flickering or crashes.
- The default PhotosPicker button style didn’t match my other buttons, so I had to make them uniform with custom styling.
- Implementing the 24-hour visibility rule was hard because it required filtering and gating posts based on the user’s last post.
- Parse server schema mismatches caused decoding errors until I fixed the data model fields and Back4App setup.
- SwiftUI async tasks sometimes updated views after they disappeared, leading to crashes until I canceled tasks properly.
- The feed header accidentally repeated on every post because I placed it inside the List instead of above it.
- Complex SwiftUI views caused type-checking errors, so I split them into smaller computed subviews.
- Coordinating pull-to-refresh, infinite scroll, and reloading after posting required centralizing my loading logic.

## License

    Copyright 2025 Jeffrey Berdeal

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
