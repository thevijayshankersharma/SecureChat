// Define the Message model and the MessageDeliveryStatus enum here
class Message {
  final String content;
  final bool isEncrypted;
  final DateTime timestamp;
  final MessageDeliveryStatus deliveryStatus;

  Message({
    required this.content,
    required this.isEncrypted,
    required this.timestamp,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });

  // Copy method to create a new Message object based on the current one
  Message copyWith({
    String? content,
    bool? isEncrypted,
    DateTime? timestamp,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return Message(
      content: content ?? this.content,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}

// Enum to represent the delivery status of the message
enum MessageDeliveryStatus {
  sent,
  delivered,
  failed,
}