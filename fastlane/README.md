fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Create a new beta build to TestFlight, generate screenshots and push everything to ITC
### ios upload_build
```
fastlane ios upload_build
```

### ios upload_metadata
```
fastlane ios upload_metadata
```
Upload metadata and screenshots
### ios generate_screenshots
```
fastlane ios generate_screenshots
```
Only generate screenshots and save them localy
### ios delete_unframed
```
fastlane ios delete_unframed
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
