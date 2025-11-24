import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextStyle commonLabelTextStyle = TextStyle(color: Colors.black, fontSize: 13);

TextStyle textStyle =
    TextStyle(color: Color.fromARGB(255, 73, 72, 72), fontSize: 12);

TextStyle AmountTextStyle =
    TextStyle(color: Color.fromARGB(255, 73, 72, 72), fontSize: 15);

const TextStyle HeadingStyle = TextStyle(
  color: Colors.black,
  fontSize: 17,
);

const TextStyle DropdownTextStyle = TextStyle(
  color: Color.fromARGB(255, 73, 72, 72),
  fontSize: 13,
);

const TextStyle topheadingbold = TextStyle(
  fontSize: 14,
  color: Colors.black,
);

const TextStyle textboxheading = TextStyle(
  color: Colors.black,
  fontSize: 13,
  // fontWeight: FontWeight.bold
);

const TextStyle textBoxstyle = TextStyle(
  color: Colors.black,
  fontSize: 13,
);

const TextStyle commonWhiteStyle = TextStyle(
  color: Colors.white,
  fontSize: 13,
);

BoxDecoration TableHeaderColor = BoxDecoration(
  color: Colors.grey[200],
);

Color buttonColor = const Color.fromARGB(255, 65, 75, 127);

const TextStyle TableRowTextStyle = TextStyle(
  color: Color.fromARGB(255, 73, 72, 72),
  fontSize: 13,
);

void successfullySavedMessage(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Saved..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void successfullyDeleteMessage(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Deleted..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void WarninngMessage(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.yellow, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.yellowAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.yellow, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kindly fill all the fields..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}

void successfullyUpdateMessage(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully Updated..!!',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}
