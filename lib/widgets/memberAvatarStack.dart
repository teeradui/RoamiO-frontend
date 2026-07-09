import 'package:flutter/material.dart';

class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 34,
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22,
            child: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://i.pinimg.com/1200x/44/4e/2e/444e2ec970ed0d571134330e123149e9.jpg')
              
            ),
          );
        }),
      ),
    );
  }
}
