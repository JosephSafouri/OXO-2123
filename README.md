<a href="/">
    <img src="https://user-images.githubusercontent.com/70985186/154367134-4963a12a-ed37-4089-8d87-2db25e7b9c9c.svg" alt="OXOS Logo" align="right" height="60" />
</a>

# Team 2123: The Destroyers
Jason Pham </br>
Joseph Safouri </br>
Damian Patel </br>
Sarah Ukani </br>
Praharsh Patel </br>

## Instructions to run app

### Prerequisites
- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Use [Mac Installation Guide](https://docs.flutter.dev/get-started/install/macos) or [Windows Installation Guide](https://docs.flutter.dev/get-started/install/windows)
- Preferably have an Android device
- Note that Android Studio is not needed to just run the app, but running the app is much easier this way.

### Dependent Libraries
Depedencies are specificied in the pubspec.yaml file so no external downloads will be required. To acquire the dependencies specified in the file follow these instructions:
1. cd into `path/to/flutter-app/flutter-drawing-app/starter/`
2. Run `flutter pub get`
3. Run `flutter pub updgrade`

After running these commands, flutter should automatically download all necessary dependencies.

### Running the application
1. Connect your Android device to your computer 
1. In your Android device, enable developer mode and then enable USB debugging. 
2. Clone the repository into your desired directory.
3. Open the project in Android Studio and open the devices tab. 
4. Click the physical tab and ensure that your device is appearing 
5. Select your device for running 
6. Run the app! 

# Release Notes
## Version 0.5.0
### Features
<ul>
    <li> Implemented feature to use pixel pitch and pixel coordinates to find accurate measurements for straight line drawing.</li>
    <li>Added feature to create multiple text boxes and allow them to be dragged. </li>
</ul>

### Bug Fixes
<ul>
    <li> Fixed toolbar so that different options are not overlapping and allows user much more screen space to draw on. </li>
    <li> Fixed problem where text was not wrapping when users inputted multiple characters into the textbox. </li>
    <li> Fixed issue where toolbar would shift back and worth depending on whether a text box was visible. </li>
</ul>

### Known Issues
<ul>
    <li> Multiple fingers on the screen causes unexpected behavior when drawing. </li>
    <li >Measurements currently do not use magnification to find distance but rather the resolution and metadata of the screen.  </li>
</ul>

## Version 0.4.0
### Features
<ul>
    <li> Implemented a feature to allow the user to make measurements with the line drawing tool.</li>
</ul>

### Bug Fixes
<ul>
    <li> When changing the colors in line drawing mode, it stays in line drawing mode instead of returning to free drawing.</li>
    <li> Exporting the image does not show the black bar anymore. </li>
</ul>

### Known Issues
<ul>
    <li> If there is no textbox, the toolbar slightly shifts from the right to the left creating a black bar.</li>
    <li> The textbox feature is still not a movable object and appears in the middle of the screen. </li>
</ul>

## Version 0.3.0
### Features
<ul>
    <li> Added a button that allows users to add a textbox within the image to do text annotation.</li>
    <li> Added a button to allow the user to export an image to your gallery with the annotations.</li>
</ul>

### Bug Fixes
<ul>
    <li> The point button has been removed and converted to the export feature.</li>
    <li> The toolbar is now a separate entity and cannot be drawn on.</li>
</ul>

### Known Issues
<ul>
    <li> When changing colors on line drawing mode, drawing state will be set to free drawing.</li>
    <li> Exported images have an a black bar where the toolbar was.</li>
    <li> The textbox feature now works but only appears in the middle of the canvas.</li>
</ul>

## Version 0.2.0
### Features
<ul>
    <li> Added a button to allow drawing a straight line</li>
    <li> Added a button to allow the user to select an image</li>
    <li> Added ability to detect whether the file is an image type or not</li>
</ul>

### Bug Fixes
<ul>
    <li> Image and tool bar are seprate, but previously they were overlapping. </li>
    <li> The background was defaulted to a solid color but now is a default image at startup.</li>
    <li> The width of the images wasn't the correct size type, but now is.</li>
</ul>

### Known Issues
<ul>
    <li> Image uploading only throws an error rather than prompt the user to select a different file.</li>
    <li> The ability to drop a point does not function but has a button.</li>
    <li> The ability to implement a textbox within the canvas does not function.</li>
    <li> We are allowed to draw on the toolbar which we do not want.</li>
</ul>

## Version 0.1.0
### Features
<ul>
    <li> Added drawing feature </li>
    <li> Added ability to change drawing </li>
    <li> Added ability to change stroke width </li>
</ul>

### Bug Fixes
<ul>
    <li> <em>No bug fixes</em> </li>
</ul>

### Known Issues
<ul>
    <li> Image uploading features needs to be implemented </li>
    <li> Straight line drawing needs to be implemented </li>
</ul>


