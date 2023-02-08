# For debugging and performance monitoring. We use Apple's Unified logging system (OSLog, OSSignpostLog).

*Refer Log.swift in "Debugging" folder.
-> To use OSLog (to be tested in a console app)

(Note:- to view data in console or instruments app represent the data in the string)

• Create a log handler aka createLog(category: String)
• For printing a log message in console use log(message: StaticString, type: OSLogType, category: String, content: CVarArg)
• Open the console app after running the project. in the search bar following steps are to be performed.
Step 1. search the message.
Step 2. When appeared right-click and select view by subsystem aka bundle identifier will appear, in order to filter.
Step 3. Filter those according to the categories by again right-clicking the message.
(OSLogType)

1. Debug: Use this level to capture information that may be useful during development or while troubleshooting a specific problem.
2. Error: Use this log level to report process-level errors.
3. Default: Use this level to capture information about things that might result in a failure.
4. Info: Use this level to capture information that may be helpful, but not essential, for troubleshooting errors.
5. Fault: Use this level only to capture system-level or multi-process information when reporting system errors.

-> To use OSSignPostLogs (to be tested in instruments app)

• Two ways to use it
1. To use it for synchronous tasks
2. To use it for asynchronous tasks

Way 1 (To use it for synchronous tasks)

• Create a log handler.
• Use osSignPost(type: OSSignpostType, log: OSLog, processName: StaticString, content: String) .There are 3 types .begin, .end, .event (explained later)
• Use the method with .begin before the process and use the same method after process with .end.

• To test. Product -> Profile.
• Instruments will open up. Click on the plus icon on the right side of the window, in the search bar search for os_signpost. Drag the row to the leftmost to the window and start recording. The processName will appear in the list. Refer to it for the monitoring process.

Way 2 (To use it for asynchronous tasks)

• Create a log handler.
• Create a signpost id with osSignPostID(log: OSLog)
• Use osSignPost(withSignPostID: OSSignpostID, type: OSSignpostType, log: OSLog, processName: StaticString, content: String)
• The usage and method of testing will be the same as above. Just multiple lists will appear in detail view of the instruments tool. Refer to the graph for visualizing the path of execution. Pinch to zoom it.

(Note:- The processName should be same in .begin and .end)

(Optional)
There is another method where a class needs to be passed in signpostid initializer. Its because when we are testing the same log in the whole process the object parameter will be used to differentiate the process in instruments.

.event will be used for monitoring the performance after a particular event is performed for example. User swipes the card, connected to the network, etc.

Create a log but with a method having the parameter of OSLog.Category and pass .pointsOfInterest
Declare the signPost method and pass pointsofInterest log in it. Drag and drop points of interest feature with the signpost. A rounded "s" icon will appear in instruments when this method gets called out.


# Using local data persistance with abstraction provided.


*Refer RepoCoreData.swift in repository layer folder. 
• The declaration will be creating the instance of below class and using the methods of this class in the instance.
• The methods that provide an abstraction are get(), create(), delete(), save(), refereshAllObjects() and reset()
• A Switch statement will be used at declaration since we are returning result type enum which will act as an alternative to do-catch blocks.


# Speeding up Xcode builds 🚀

In Xcode -> Targets -> Krown -> Build settings 

-> These are default enabled but in some cases aren't enabled by system) 

• From project icon which is left to simulator option. Select edit scheme and ensure parallel build is enabled. 
• In Xcode -> files -> Workspace settings. Ensure "new build system" is selected. 

-> Select Target -> Krown, in our project settings where in "Build settings"

•  In Architectures -> Ensure active architecture is enabled in debug mode. 

• In Build options -> Debug info format -> Debug mode 
 click plus icon and add "Any iOS Simulator SDK" select DWARF for it and then add"any iOS SDK" select DWARF with dSYM for it.
 
(It's DWARF only for "Any iOS Simulator SDK" is because we don't want to generate dSYM files for every build and also their generation is time consuming since we will be debugging from simulator)
(DWARF is format of debugging file). Doesn't affect debugging. 

• In Swift Compiler -> Code generation -> Select optimisation to "optimise for speed" for debug mode. 

-> Refer the following commands from terminal after selecting our project directory.

=> This command will allow Xcode to build the project on multiple threads.

defaults write com.apple.Xcode PBXNumberOfParallelBuildSubtasks 2 
 
• By default Xcode chooses amount of threads as the amount of cores. 
• Threads can be customised to 2, 3, 4, 8 
• It's a hit or miss which number will provide best results but I observed choosing the 2x amount of cores for optimal results. 

=> Allow Xcode to execute parallel tasks

defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool YES

=> To show number of seconds in build view 

defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

Reference:- https://gist.github.com/nlutsenko/ee245fbd239087d22137

Final step -> Clean and build 👍🏼


# SwiftUI previews of UIKit
• Bridiging files to SwiftUI are created for the MenuVC (MenuVCSwiftUIBridge), HomeVC (HomeVCSwiftUIBridge) and ChatListVC (ChatListVCSwiftUIBridge)
• HomeTabBarVC.swift is the SwiftUI file that shows three UIViewConrollers mentioned in the previous bullet

-> currently SwiftUI Previews don't run network calls. In order to make Previews run disable the following:
• In HomeVC.swift comment out the call to connectToXMPPChatServer() in viewDidLoad (line 104)
• In ChatListVC.swift comment out the call to refreshmatchesList() in viewDidLoad (line 34)
• In MenuVC.swift comment out the call to reloadMenu() in viewDidLoad (line 28) and the lines 54 (let firstname: String =.....) and 55 (name.text = firstname) in MenuTableViewMainCell.swift

-> UIViewController class is extended in the file UIViewController+Preview.swift so you can use SwiftUI preview in every UIViewController (for an example of implementation take a look at the bottom of the e.g. HomeVC.swift)

General info: in order for SwiftUI Previews to work, following settings were changed:
• In Build Settings, optimization level (search for "Optimization" in Build Settings) for the debug config are set to either -Onone (No optimization), or -O0 (None)
• In Build Settings search for "Active Compilation Conditions" and add "DEBUG" in the debug configuration. This solves the "previewInstances" crash of the Preview canvas
