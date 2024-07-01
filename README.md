# ScreenSaverGallery
Welcome to the ScreenSaverGallery project! This repository contains the code for a unique screensaver (ScreenSaverGallery), transforming your screen into a gallery of digital and online art. 

## About
ScreenSaverGallery is an innovative project that merges the worlds of digital art and screen savers. Our aim is to breathe new life into the screensaver medium by turning it into a dynamic canvas for contemporary art. The screensaver showcases artworks that either act as screen savers or thematize virtual space, networking, and digital interaction. It is not just a platform for presenting art but also an experimental environment for its development.

Artworks in the ScreenSaverGallery are curated to add a new dimension by placing them in the context of a screensaver. Curators, artists, researchers and developers are invited to explore and experiment with the possibilities offered by this medium.

## Installation
### For Developers: 
1. Clone the repository: ```git clone https://github.com/ScreenSaverGallery/macos.git```
2. Open the project in Xcode (v16.0 or later) and build the screensaver.
> Note: You must add `Info.plist` files to `ScreenSaver` and `SSGPreview` directories to set the `SSG_URL` and `SSG_URL_DEV` parameters. These urls are not yet publicly available as the content is subject to further development. If you want to participate on ScreenSaverGallery project, feel free to contact us to get the active urls. If you want to use this code for your own needs, set up urls of your choice.
### For Users:
1. Go to [ScreenSaverGallery](https://screensaver.gallery/get) website
2. Download and install the latest ScreenSaverGallery
3. Set the ScreenSaverGallery as your default screensaver in System Preferences.

## How It Works
The technical implementation of ScreenSaverGallery is straightforward yet effective. The screensaver is essentially a WebView that displays curated content from a specified URL. 

## Features
- Display a variety of digital and online artworks as a screensaver.
- Control screensaver's sound by mute or unmute them in the ScreenSaverGallery preferences by setting WebView navigator param `muted=true`.
- Allow or dissable potentially inappropriate content in the ScreenSaverGallery preferences by setting WebView navigator param `adult=false`.
- Support service worker for offline mode.

## History
ScreenSaverGallery was first launched by artists Barbora Trnkova and Tomas Javurek in 2012 as an artistic, somewhat ironic, project. In 2013, together with artist and curator c-merry and curator Sakrowski, we launched a continuous exhibition program that continues to this day. You can see the list of screensavers [here](https://screensaver.gallery/archive/screensavers). 

## Contributing

We welcome contributions from developers, artists, and enthusiasts! Here’s how you can get involved:

### Reporting Issues
If you encounter any bugs or have suggestions for improvements, please open an issue on GitHub.

### Submitting Pull Requests
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with clear, concise messages.
4. Push your changes to your forked repository.
5. Submit a pull request detailing your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
