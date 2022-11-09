<a href="/">
    <img src="https://user-images.githubusercontent.com/70985186/154367134-4963a12a-ed37-4089-8d87-2db25e7b9c9c.svg" alt="OXOS Logo" align="right" height="60" />
</a>

# Team 2123: The Destroyers
Jason Pham </br>
Joseph Safouri </br>
Damian Patel </br>
Sarah Ukani </br>
Praharsh Patel </br>

#### Instructions to run app
- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Use [Mac Installation Guide](https://docs.flutter.dev/get-started/install/macos) or [Windows Installation Guide](https://docs.flutter.dev/get-started/install/windows)
- Note that Android Studio is not needed to just run the app
- Pull main branch from repository
- cd into the `flutter-app/flutter_drawing_app/starter/` directory and run `flutter run` in the command line
- Chrome tab should open up and display the running app

# Release Notes
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


