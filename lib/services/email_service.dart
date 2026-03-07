import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String senderEmail;
  final String senderPassword;
  final String smtpHost;
  final int smtpPort;

  const EmailService({
    required this.senderEmail,
    required this.senderPassword,
    this.smtpHost = 'smtp.gmail.com',
    this.smtpPort = 587,
  });

  Future<void> sendReport({
    required List<String> recipients,
    required String subject,
    required String body,
    List<File> attachments = const [],
  }) async {
    final smtpServer = SmtpServer(
      smtpHost,
      port: smtpPort,
      username: senderEmail,
      password: senderPassword,
      ssl: false,
      allowInsecure: false,
    );

    final message = Message()
      ..from = Address(senderEmail, 'Mess Hisab Tracker')
      ..recipients.addAll(recipients)
      ..subject = subject
      ..text = body;

    for (final file in attachments) {
      message.attachments.add(FileAttachment(file));
    }

    await send(message, smtpServer);
  }

  Future<void> sendMonthlyReport({
    required List<String> recipients,
    required String monthLabel,
    required String reportText,
    File? pdfFile,
    File? excelFile,
  }) async {
    final attachments = [
      if (pdfFile != null) pdfFile,
      if (excelFile != null) excelFile,
    ];

    await sendReport(
      recipients: recipients,
      subject: 'Mess Hisab - $monthLabel',
      body: reportText,
      attachments: attachments,
    );
  }
}
