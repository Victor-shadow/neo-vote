import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neo_vote/core/utils/constants.dart';

class VoteTimerWidget extends StatefulWidget {
  const VoteTimerWidget({super.key});

  @override
  State<VoteTimerWidget> createState() => _VoteTimerWidgetState();
}

class _VoteTimerWidgetState extends State<VoteTimerWidget> {
  late Timer _timer;
  int _secondsRemaining = AppConstants.voteSessionTimeoutSeconds;

  @override
  void initState(){
    super.initState();
    _startTimer();
  }

  void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(_secondsRemaining > 0){
        if(mounted){
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer.cancel();
        //Automatically pop the screen when the timer
        if(mounted){
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voting session timed out for security')),
          );
        }
      }
    });
  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final isLowTime = _secondsRemaining < 60;

    return Container(
      width: double.infinity,
      color: isLowTime ? Colors.red.shade100 : Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Text(
          'Session expires in: $minutes:$seconds',
          style: TextStyle(
            color: isLowTime ? Colors.red.shade900 : Colors.amber.shade900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}