import 'package:uuid/uuid.dart';

// Define the Message model and the MessageDeliveryStatus enum here
class Message {
  final String id;
  final String content;
  final bool isEncrypted;
  final DateTime timestamp;
  final MessageDeliveryStatus deliveryStatus;
  final String recipient;

  Message({
    String? id,
    required this.content,
    required this.isEncrypted,
    required this.timestamp,
    required this.recipient,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  }) : this.id = id ?? Uuid().v4();

  // Copy method to create a new Message object based on the current one
  Message copyWith({
    String? id,
    String? content,
    bool? isEncrypted,
    DateTime? timestamp,
    MessageDeliveryStatus? deliveryStatus,
    String? recipient,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      recipient: recipient ?? this.recipient,
    );
  }

  // Convert a Message into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isEncrypted': isEncrypted,
      'timestamp': timestamp.toIso8601String(),
      'deliveryStatus': deliveryStatus.toString(),
      'recipient': recipient,
    };
  }

  // Create a Message from a Map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isEncrypted: json['isEncrypted'],
      timestamp: DateTime.parse(json['timestamp']),
      deliveryStatus: MessageDeliveryStatus.values.firstWhere(
        (e) => e.toString() == json['deliveryStatus'],
        orElse: () => MessageDeliveryStatus.sent,
      ),
      recipient: json['recipient'],
    );
  }
}

// Enum to represent the delivery status of the message
enum MessageDeliveryStatus {
  sent,
  delivered,
  failed,
}

