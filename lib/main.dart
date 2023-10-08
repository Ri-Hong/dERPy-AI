import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Message {
  final String text;
  final bool isUser; // true if the message is from the user, false if from the chatbot

  Message({required this.text, required this.isUser});
}

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

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _messages.insert(0, Message(text: _textController.text, isUser: true));
        _messages.insert(0, Message(text: "Bot reply to: ${_textController.text}", isUser: false));
      });
      _textController.clear();
    }
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
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.isUser ? Color.fromARGB(255, 36, 213, 190) : Color.fromARGB(255, 148, 151, 167),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.black),
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
                      hintText: 'Ask Derpy a question!',
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
                        width: 45, // Set a fixed width for the container
                        height: 45, // Set a fixed height for the container
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 29, 221, 195),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.only(right: 7.0),
                        child: MouseRegion(
                          onHover: (event) {
                            // Handle hover effect here if needed
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: ClipRRect( // Add this
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
