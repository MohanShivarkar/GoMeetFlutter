import 'package:dating/core/ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool alingment;
  final Color chatColor;
  final Color textColor;
  const ChatBubble({super.key, required this.message, required this.alingment, required this.chatColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(alingment ? 0 : 12),
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomRight: Radius.circular(alingment ? 12 : 0)),
        color: chatColor,
      ),
      child: Text(
        message,
        style: TextStyle(

            fontSize: 16,
            color: textColor,
           ),
      ),
    );
  }
}


class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
  });

  final bool isMe;
  final Message message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      widget.isMe ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.grey.shade100 : AppColors.appColor,
          // border: Border.all(color: widget.isMe ? notifier.border : Colors.transparent),
          borderRadius: widget.isMe
              ? const BorderRadius.only(
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
            topLeft: Radius.circular(13),
          )
              : const BorderRadius.only(
            topRight: Radius.circular(13),
            bottomLeft: Radius.circular(13),
            topLeft: Radius.circular(13),
          ),
        ),
        margin: const EdgeInsets.only(
            top: 10, right: 10, left: 10),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.isMe
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
                widget.message.message,
                style: TextStyle(
                    fontSize: 16,
                    // fontFamily: FontFamily.gilroyExtraBold,
                    color: widget.isMe ? AppColors.black : AppColors.white)),
            const SizedBox(height: 5),
            Text(
                DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.message.timestamp.microsecondsSinceEpoch)).toString(),
              style:  TextStyle(
                color: widget.isMe ? AppColors.black : AppColors.white,
                fontSize: 10,
              ),),
          ],
        ),
      ),
    );
  }
}

