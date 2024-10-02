//  this section we design somethiing cool
import 'package:flutter/material.dart';

class OurinputField extends StatefulWidget {
  //  the various things needed
  final String hintText;
  final IconData PrefixIcon;
  final void Function(String) onchange;

  const OurinputField({
    Key? key,
    required this.hintText,
    required this.PrefixIcon,
    required this.onchange,
  }) : super(key: key);
  @override
  State<OurinputField> createState() => _OurinputFieldState();
}
class _OurinputFieldState extends State<OurinputField> {
  @override
  Widget build(BuildContext context) {
    return  Container(
 decoration: BoxDecoration(
   borderRadius: BorderRadius.circular(20),
 ),
// ignore: prefer_const_constructors
padding: EdgeInsets.all(6),
      child: Center( 
child:  TextField(
          decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(
                widget.PrefixIcon,
                size: 12,
              )
              ,
            
              ),
              onChanged:widget.onchange,
              style: const TextStyle( fontSize: 20)
              ,
            )
               ,
      ),
// then in here we do the thing of making the what ermmm .... it to be possition center 

    );
  }
}
