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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otherBgColor = isDark ? const Color(0xFF262433) : Colors.grey.shade200;
    final otherTextColor = isDark ? Colors.white : Colors.black87;
    final otherTimeColor = isDark ? Colors.white60 : Colors.black54;

    return Align(
      alignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isMe ? AppColors.appColor : otherBgColor,
          borderRadius: widget.isMe
              ? const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(14),
                ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.message,
              style: TextStyle(
                fontSize: 15,
                color: widget.isMe ? Colors.white : otherTextColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.message.timestamp.microsecondsSinceEpoch)),
                  style: TextStyle(
                    color: widget.isMe ? Colors.white70 : otherTimeColor,
                    fontSize: 10,
                  ),
                ),
                if (widget.isMe) ...[
                  const SizedBox(width: 4),
                  widget.message.isRead
                      ? const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF4FC3F7))
                      : const Icon(Icons.done_rounded, size: 14, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

