import 'package:flutter/material.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  TextEditingController _issueController = TextEditingController();
  List<QueryResponse> queriesAndResponses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color.fromRGBO(87, 213, 236, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Support",
          style: TextStyle(
            color: Color.fromRGBO(87, 213, 236, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildQueryList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildQueryList() {
    return ListView.builder(
      itemCount: queriesAndResponses.length,
      itemBuilder: (context, index) {
        String query = queriesAndResponses[index].query;

        return SizedBox(
          child: Card(
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              title: Text(
                query,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.82,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(209, 209, 209, 1),
                  blurRadius: 50,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                elevation: 0,
                child: TextFormField(
                  controller: _issueController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    label: Text("Enter Message"),
                    filled: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(87, 213, 236, 1),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: IconButton(
              onPressed: () {
                _submitQuery();
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _submitQuery() {
    String userQuery = _issueController.text.trim();
    if (userQuery.isNotEmpty) {
      // Simulate admin response after a while (you would use backend logic here)
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          queriesAndResponses
              .add(QueryResponse(query: userQuery, response: "Admin response"));
          _issueController.clear();
        });
      });
    }
  }
}

class QueryResponse {
  final String query;
  final String? response;

  QueryResponse({required this.query, this.response});
}
