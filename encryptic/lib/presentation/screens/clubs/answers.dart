import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/home/clubs/clubs_bloc.dart';
import '../../../bloc/home/clubs/clubs_event.dart';
import '../../../bloc/home/clubs/clubs_state.dart';
import '../../../data/Models/Answer.dart';
import '../../../data/Models/Question.dart';

class Answers extends StatefulWidget {
  final String url;
  final Question question;

  const Answers({super.key, required this.url, required this.question});

  @override
  State<Answers> createState() => _QuestionsState();
}

class _QuestionsState extends State<Answers> with SingleTickerProviderStateMixin {
  double width = 0;
  bool myAnimation = false;
  final TextEditingController _answerController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 500, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Trigger the animation when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      setState(() {
        myAnimation = true;
      });
      _animationController.forward();  // Start the animation
    });
  }

  @override
  void dispose() {
    // Dispose the AnimationController
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(children: [
            QuestionCardWithAnswer(context, widget.question, _answerController),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: BlocProvider(
                create: (context) => ClubsBloc(homeRepository: context.read())
                  ..add(FetchAnswerForClub(widget.question.id)),
                child: BlocConsumer<ClubsBloc, ClubsState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is ClubsAnswerLoaded) {
                      print("Rebuilding UI with updated questions");
                      final answers = state.answerList;

                      if (answers.isEmpty) {
                        return Center(
                            child: Text(
                              "No Answers Yet....",
                              style: TextStyle(color: Colors.white),
                            ));
                      } else {
                        return AnswerCard(
                            context, myAnimation, width, answers, _animationController, _animation);
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
                                .add(FetchAnswerForClub(widget.question.id));
                          },
                        ),
                      );
                    } else {
                      return Center(child: Text("No data available."));
                    }
                  },
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

Widget QuestionCardWithAnswer(BuildContext context, Question question,
    TextEditingController answerController) {
  return Hero(
    tag: "question-card ${question.content}",
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
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
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
                      radius: MediaQuery.of(context).size.width > 375 ? 25 : 20,
                      backgroundImage: CachedNetworkImageProvider(
                        question.authorImage ?? '',
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
                        question.authorName ?? "Username",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width > 375 ? 15 : 12,
                          fontFamily: 'Orbitron_black',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Text(
                        question.tags
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: TextStyle(
                          overflow: TextOverflow.fade,
                          fontSize: MediaQuery.of(context).size.width > 375
                              ? 12.5
                              : 10,
                          fontFamily: 'Orbitron_black',
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      )
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      DateFormat("MM-dd-yyyy \n HH:mm")
                          .format(question.createdAt),
                      style: TextStyle(
                        overflow: TextOverflow.fade,
                        fontSize:
                            MediaQuery.of(context).size.width > 375 ? 11 : 10,
                        fontFamily: 'Orbitron_black',
                        color: Theme.of(context).colorScheme.secondaryContainer,
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
                      question.content ?? "Question Text",
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 375 ? 20 : 12,
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
                            question.content ?? "Question Text",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 375
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // "See All Ans." Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Back',
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
                                        MediaQuery.of(context).size.width > 375
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
                                        MediaQuery.of(context).size.width > 375
                                            ? 20
                                            : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Matches theme
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Write your answer here...',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
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
                                        fontSize:
                                            MediaQuery.of(context).size.width >
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
}

Widget AnswerCard(BuildContext context, bool myAnimation, double width, List<Answer> answers, AnimationController _animationController, Animation<double> _animation) {
  return ListView.builder(
      shrinkWrap: true,
      itemCount: answers.length,
      itemBuilder: (context, index) {
        // Use the animation's value for translation
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final offset = _animation.value;  // Using animation value directly
            return AnimatedContainer(
                duration: Duration(milliseconds: 400 + (index * 250)),
                curve: Curves.easeIn,
                transform: Matrix4.translationValues(offset, 0, 0),  // Apply translation
                child: Card(
                  elevation: 5, // Shadow depth
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35), // Rounded corners
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
                      margin: EdgeInsets.all(1), // Padding for the inner card
                      padding: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Inner container background
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius:
                                        MediaQuery.of(context).size.width > 375
                                            ? 20
                                            : 15,
                                        backgroundImage: CachedNetworkImageProvider(
                                            answers[index].authorProfileImage),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width > 375
                                          ? 10
                                          : 5,
                                    ),
                                    Text(
                                      answers[index].authorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                        MediaQuery.of(context).size.width > 375
                                            ? 15
                                            : 12,
                                        fontFamily: 'Orbitron_black',
                                        color:
                                        Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  DateFormat("MM-dd-yyyy \n HH:mm")
                                      .format(answers[index].createdAt),
                                  style: TextStyle(
                                    overflow: TextOverflow.fade,
                                    fontSize:
                                    MediaQuery.of(context).size.width > 375
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
                                  answers[index].content,
                                  style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.width > 375
                                        ? 15
                                        : 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2, // Limits the text to 3 lines
                                  overflow: TextOverflow
                                      .ellipsis, // Truncates the text with ellipsis if it overflows
                                  softWrap:
                                  true, // Ensures text wraps to the next line
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
                                        answers[index].content,
                                        style: TextStyle(
                                          fontSize:
                                          MediaQuery.of(context).size.width >
                                              375
                                              ? 15
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
                        ],
                      ),
                    ),
                  ),
                ));
          },
        );
      });
}
