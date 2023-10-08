import 'package:flutter/material.dart';
import 'dart:math'; // Import for the Random class
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';


void main() {
  runApp(const MyApp());
}

class Message {
  String text;
  final bool isUser; // true if the message is from the user, false if from the chatbot
  bool isLoading; // New attribute to track loading state for each message
  int iconIndex; // to track the current icon in the sequence
  int promptIndex; // to track the associated prompt index for each bot message

  Message({required this.text, required this.isUser, this.isLoading = false, this.iconIndex = 0, required this.promptIndex});
}


// Sample data
List<String> responses = [
  "Who is this for?",
  "It seems like this customer doesn't exist in our records. Would you like to create a new customer record?",
  "Great, David has been added in the contacts module <Insert Link>. What products are David interested in?",
  "Invoice <Insert ID Here> successfully created! You can check it out in the sales module <Insert Link>.",
];

List<List<String>> icons = [
  ['assets/OdooSalesIcon.png'],
  ['assets/OdooContactsIcon.png'],
  ['assets/OdooContactsIcon.png', 'assets/OdooSalesIcon.png'],
  ['assets/OdooInventoryIcon.png', 'assets/OdooSalesIcon.png']
];

List<String> links = [
  "A Link",
  "B Link",
  "C Link",
  "D Link",
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fixed super.key to Key? key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(30, 82, 82, 82)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'dERPy AI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key); // Fixed super.key to Key? key
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false; // New state variable
  int currentPromptIndex = 0; // New state variable to track the current prompt index

void _sendMessage() {
  if (_textController.text.isNotEmpty) {
    setState(() {
      _messages.insert(0, Message(text: _textController.text, isUser: true, promptIndex: currentPromptIndex));
      _messages.insert(0, Message(text: "", isUser: false, isLoading: true, iconIndex: -1, promptIndex: currentPromptIndex)); // Set iconIndex to -1 for no icon initially
    });
    
    _sequenceIconsAndResponse(currentPromptIndex, _messages[0]); // Pass the specific message to the method
    currentPromptIndex++; // Increment the prompt index for the next user prompt

    _textController.clear();  // Clear the textfield
  }
}
void _sequenceIconsAndResponse(int promptIndex, Message message) {
  // Introduce a delay before starting the icon sequence
  Future.delayed(Duration(seconds: 1), () {
    if (message.iconIndex < icons[promptIndex].length - 1) {
      // Increment the iconIndex to start the icon sequence
      setState(() {
        message.iconIndex++;
      });

      // If there are more icons in the sequence, show the next one after a delay
      Future.delayed(Duration(seconds: Random().nextInt(3) + 2), () {
        _sequenceIconsAndResponse(promptIndex, message); // Recursive call with the specific message
      });
    } else {
      // If all icons in the sequence have been shown, display the bot response immediately
      setState(() {
        message.text = responses[promptIndex];
        message.isLoading = false;
      });
    }
  });
}



List<TextSpan> _parseResponse(String response, String linkUrl) {
  List<TextSpan> spans = [];
  var parts = response.split('<Insert Link>');

  for (int i = 0; i < parts.length; i++) {
    spans.add(TextSpan(text: parts[i]));
    if (i < parts.length - 1) {
      spans.add(TextSpan(
        text: 'here',
        style: TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Open the link
            launch(linkUrl);
          },
      ));
    }
  }
  return spans;
}



  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(30, 82, 82, 82),
        title: Padding(
          padding: EdgeInsets.only(top: 10.0), // Add 10 pixels of padding above the image
          child: Image.asset('assets/derpyHeader.png', fit: BoxFit.cover, height: 30,), // Adjust height as needed
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: IntrinsicWidth( // Add this widget
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: message.isUser ? Color.fromARGB(255, 167, 238, 229) : Color.fromARGB(255, 228, 228, 225),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: message.isUser
                        ? Text(
                            message.text,
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.right,
                          )
                        : message.isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (message.iconIndex >= 0) ...[ // Use the spread operator
                                Image.asset(icons[message.promptIndex][message.iconIndex], fit: BoxFit.cover, height: 30,),
                                SizedBox(width: 8.0), // Spacing between the icon and the loading GIF
                              ],
                              Container(
                                width: 50.0,  // Set the desired width for the loading GIF
                                height: 50.0, // Set the desired height for the loading GIF
                                child: Image.asset('assets/loading.gif'),
                              ),
                            ],
                          )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(icons[message.promptIndex][message.iconIndex], fit: BoxFit.cover, height: 30,),
                                  SizedBox(width: 8.0),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                    child: RichText( // <-- This is the new part
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: _parseResponse(message.text, links[message.promptIndex]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
  
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust the vertical padding
                      hintText: 'Ask Derpy for help!',
                      hoverColor: Colors.transparent,  // Disable hover effect
                      hintStyle: TextStyle(color: Color.fromARGB(255, 111, 116, 141).withOpacity(0.8)), // Adjust the opacity as needed
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust for desired roundness
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      filled: true, // Add this line
                      fillColor: Color.fromARGB(255, 167, 238, 229), // Change to your desired color
                      suffixIcon: Container(
                        width: 30, // Set a fixed width for the container
                        height: 30, // Set a fixed height for the container
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 29, 221, 195),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.only(right: 4.0),
                        child: MouseRegion(
                          onHover: (event) {
                            // Handle hover effect here if needed
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0), // Match the Container's borderRadius
                              child: InkWell(
                                onTap: _sendMessage,
                                child: Center(child: Icon(Icons.send, color: Colors.black)), // Center the icon
                              ),
                            ),
                          ),
                        ),
                      ),

                    ),
                    onSubmitted: (text) {
                      _sendMessage();
                    },
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
