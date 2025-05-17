import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/home/clubs/clubs_bloc.dart';
import '../../../bloc/home/clubs/clubs_event.dart';
import '../../../bloc/home/clubs/clubs_state.dart';
import '../../../data/Models/Question.dart';
import 'answers.dart';

class Questions extends StatefulWidget {
  final String clubName;
  final int clubId;
  final int userId;
  const Questions(
      {super.key,
      required this.clubName,
      required this.clubId,
      required this.userId});

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  List<String> tags = [];

  // Function to convert input into list of tags
  void onTextChanged(String input) {
    setState(() {
      // Split the input string by commas and trim spaces from each tag
      tags = input.split(',').map((tag) => tag.trim()).toList();
      print(tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          addQuestion(context, _tagController, _questionController),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 35,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 65,
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.clubName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Orbitron_black',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: BlocProvider(
                  create: (context) => ClubsBloc(homeRepository: context.read())
                    ..add(FetchQuestionsForClub(widget.clubId)),
                  child: BlocConsumer<ClubsBloc, ClubsState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is ClubsQuestionLoaded) {
                        print("Rebuilding UI with updated questions");
                        final questions = state.questionsList;

                        if (questions.isEmpty) {
                          return Center(child: Text("No Questions Available"));
                        } else {
                          return QuestionCardList(
                              context, questions, _answerController, widget.userId);
                        }
                      } else if (state is ClubsQuestionLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is ClubsError) {
                        return Center(
                          child: InkWell(
                            child: Text(
                              "An error occurred. Tap to retry.",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              context
                                  .read<ClubsBloc>()
                                  .add(FetchQuestionsForClub(widget.clubId));
                            },
                          ),
                        );
                      } else {
                        return Center(child: Text("No data available."));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addQuestion(BuildContext context, TextEditingController tagController,
      TextEditingController questionController) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        shape: BoxShape.rectangle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
      ),
      child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SingleChildScrollView(
                child: AlertDialog(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary, // Matches theme
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Rounded corners for dialog
                  ),
                  title: Text(
                    'What do you want to aks....',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 375 ? 20 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Orbitron_black',
                    ),
                  ),
                  content: Column(
                    children: [
                      TextField(
                        controller: tagController,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 375 ? 20 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Matches theme
                        ),
                        decoration: InputDecoration(
                          // hintText: 'Add a Tag',
                          labelText: "Enter Tags (comma separated)",
                          labelStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 375
                                ? 20
                                : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                                .withOpacity(0.5), // Matches theme hint color
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  20)), // Removes borders and lines
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .secondary, // Subtle background
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        cursorColor: Theme.of(context)
                            .primaryColor, // Matches theme primary color
                        onChanged: (input) {
                          setState(() {
                            tags = input
                                .split(',')
                                .map((tag) => tag.trim())
                                .toList();
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: questionController,
                        maxLines: 6,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 375 ? 20 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Matches theme
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your question here...',
                          hintStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 375
                                ? 20
                                : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                                .withOpacity(0.5), // Matches theme hint color
                          ),
                          border: InputBorder.none, // Removes borders and lines
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .secondary, // Subtle background
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        cursorColor: Theme.of(context)
                            .primaryColor, // Matches theme primary color
                        onChanged: (value) {
                          // Handle input change if needed
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Closes the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 375 ? 20 : 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .error, // Matches theme error color
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final content = _questionController.text;

                        if (content.isEmpty || tags.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Please provide both question and tags!")),
                          );
                          return;
                        }

                        context.read<ClubsBloc>().add(
                              AddQuestionToClub(
                                clubId: widget.clubId,
                                content: content,
                                tags: tags,
                                userId: widget
                                    .userId, // Replace with the actual user ID
                              ),
                            );
                        context
                            .read<ClubsBloc>()
                            .add(FetchQuestionsForClub(widget.clubId));
                        tagController.clear();
                        questionController.clear();
                        // Handle the submit action here
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer, // Matches theme primary color
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary, // Contrasting text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded button
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16, // Matches other text styles
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          )),
    );
  }
}

Widget QuestionCardList(BuildContext context, List<Question> questions,
    TextEditingController answerController, int userId) {
  return ListView.builder(
    itemCount: questions.length,
    itemBuilder: (context, index) {
      return Hero(
        tag: "question-card ${questions[index].content}",
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                  Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius:
                              MediaQuery.of(context).size.width > 375 ? 25 : 20,
                          backgroundImage: CachedNetworkImageProvider(
                            questions[index].authorImage ?? '',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 375 ? 10 : 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[index].authorName ?? "Username",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width > 375
                                  ? 15
                                  : 12,
                              fontFamily: 'Orbitron_black',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            questions[index]
                                .tags
                                .toString()
                                .replaceAll('[', '')
                                .replaceAll(']', ''),
                            style: TextStyle(
                              overflow: TextOverflow.fade,
                              fontSize: MediaQuery.of(context).size.width > 375
                                  ? 12.5
                                  : 10,
                              fontFamily: 'Orbitron_black',
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                          )
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(
                          DateFormat("MM-dd-yyyy \n HH:mm")
                              .format(questions[index].createdAt),
                          style: TextStyle(
                            overflow: TextOverflow.fade,
                            fontSize: MediaQuery.of(context).size.width > 375
                                ? 11
                                : 10,
                            fontFamily: 'Orbitron_black',
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          questions[index].content ?? "Question Text",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 375
                                ? 20
                                : 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            content: SingleChildScrollView(
                              child: Text(
                                questions[index].content ?? "Question Text",
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 375
                                          ? 20
                                          : 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Close",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // "See All Ans." Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      Answers(
                                          url: questions[index].authorImage ??
                                              '',
                                        question: questions[index],
                                      ),
                                  transitionDuration:
                                      Duration(milliseconds: 500),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              'See All Ans.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontFamily: 'Orbitron_black',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        // "Answer" Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SingleChildScrollView(
                                  child: AlertDialog(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondary, // Matches theme
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Rounded corners for dialog
                                    ),
                                    title: Text(
                                      'Type Your Answer',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    375
                                                ? 20
                                                : 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Orbitron_black',
                                      ),
                                    ),
                                    content: TextField(
                                      controller: answerController,
                                      maxLines: 6,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    375
                                                ? 20
                                                : 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Matches theme
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Write your answer here...',
                                        hintStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  375
                                              ? 20
                                              : 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(
                                              0.5), // Matches theme hint color
                                        ),
                                        border: InputBorder
                                            .none, // Removes borders and lines
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .secondary, // Subtle background
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      cursorColor: Theme.of(context)
                                          .primaryColor, // Matches theme primary color
                                      onChanged: (value) {
                                        // Handle input change if needed
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {

                                          Navigator.pop(
                                              context); // Closes the dialog
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    375
                                                ? 20
                                                : 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error, // Matches theme error color
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {

                                          final content = answerController.text;

                                          if (content.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Please provide an Answer!")),
                                            );
                                            return;
                                          }

                                          context.read<ClubsBloc>().add(
                                            AddAnswerToClub(
                                              questionId: questions[index].id,
                                              content: content,
                                              userId: userId
                                            ),
                                          );

                                          // Handle the submit action here
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer, // Matches theme primary color
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary, // Contrasting text color
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // Rounded button
                                          ),
                                        ),
                                        child: Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontFamily: 'Orbitron_black',
                                            fontSize:
                                                16, // Matches other text styles
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              'Answer',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Orbitron_black',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
