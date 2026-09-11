import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../gemini_config.dart';
import 'products_screen.dart';
import 'sales_screen.dart';

class AssistantScreen extends StatefulWidget {
  final String selectedLanguage;

  const AssistantScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  // ============================================================
  // SPEECH TO TEXT
  // ============================================================

  final stt.SpeechToText speech =
      stt.SpeechToText();

  bool speechAvailable = false;
  bool isListening = false;

  // ============================================================
  // AI
  // ============================================================

  bool isLoading = false;

  // ============================================================
  // CHAT MESSAGES
  // ============================================================

  final List<Map<String, String>> messages = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    messages.add({
      'sender': 'ai',
      'message': getWelcomeMessage(),
    });

    initializeSpeech();
  }

  // ============================================================
  // WELCOME MESSAGE
  // ============================================================

  String getWelcomeMessage() {
    if (widget.selectedLanguage == 'Hindi') {
      return 'नमस्ते! 👋 मैं ShilpSetu AI हूँ। आज मैं आपके हस्तशिल्प व्यवसाय में कैसे मदद कर सकता हूँ?';
    }

    if (widget.selectedLanguage == 'Telugu') {
      return 'నమస్తే! 👋 నేను ShilpSetu AI. మీ హస్తకళల వ్యాపారంలో ఈరోజు మీకు ఎలా సహాయం చేయగలను?';
    }

    return 'Namaste! 👋 I am ShilpSetu AI. How can I help you with your craft business today?';
  }

  // ============================================================
  // SPEECH LANGUAGE
  // ============================================================

  String getSpeechLocale() {
    if (widget.selectedLanguage == 'Hindi') {
      return 'hi-IN';
    }

    if (widget.selectedLanguage == 'Telugu') {
      return 'te-IN';
    }

    return 'en-IN';
  }

  // ============================================================
  // INITIALIZE SPEECH
  // ============================================================

  Future<void> initializeSpeech() async {
    try {
      final available = await speech.initialize(
        onStatus: (status) {
          debugPrint(
            'Speech status: $status',
          );

          if (!mounted) return;

          if (status == 'done' ||
              status == 'notListening') {
            setState(() {
              isListening = false;
            });
          }
        },
        onError: (error) {
          debugPrint(
            'Speech error: ${error.errorMsg}',
          );

          if (!mounted) return;

          setState(() {
            isListening = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Speech error: ${error.errorMsg}',
              ),
            ),
          );
        },
      );

      debugPrint(
        'Speech available: $available',
      );

      if (!mounted) return;

      setState(() {
        speechAvailable = available;
      });
    } catch (e) {
      debugPrint(
        'Speech initialization error: $e',
      );

      if (!mounted) return;

      setState(() {
        speechAvailable = false;
        isListening = false;
      });
    }
  }

  // ============================================================
  // VOICE INPUT
  // ============================================================

  Future<void> toggleListening() async {
    // ----------------------------------------------------------
    // STOP LISTENING
    // ----------------------------------------------------------

    if (isListening) {
      await speech.stop();

      if (mounted) {
        setState(() {
          isListening = false;
        });
      }

      return;
    }

    // ----------------------------------------------------------
    // CHECK / INITIALIZE SPEECH
    // ----------------------------------------------------------

    try {
      final available = await speech.initialize(
        onStatus: (status) {
          debugPrint(
            'Speech status: $status',
          );

          if (!mounted) return;

          if (status == 'done' ||
              status == 'notListening') {
            setState(() {
              isListening = false;
            });
          }
        },
        onError: (error) {
          debugPrint(
            'Speech error: ${error.errorMsg}',
          );

          if (!mounted) return;

          setState(() {
            isListening = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Speech error: ${error.errorMsg}',
              ),
            ),
          );
        },
      );

      debugPrint(
        'Speech available after re-check: $available',
      );

      if (!available) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition is not available. Please check microphone permission and Google voice recognition on your phone.',
            ),
            duration: Duration(seconds: 4),
          ),
        );

        setState(() {
          speechAvailable = false;
        });

        return;
      }

      // --------------------------------------------------------
      // START LISTENING
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        speechAvailable = true;
        isListening = true;
      });

      debugPrint(
        'Starting speech recognition...',
      );

      debugPrint(
        'Speech language: ${getSpeechLocale()}',
      );

      await speech.listen(
        onResult: onSpeechResult,

        // Selected language
        localeId: getSpeechLocale(),

        listenOptions: stt.SpeechListenOptions(
          partialResults: true,

          listenFor: const Duration(
            seconds: 30,
          ),

          pauseFor: const Duration(
            seconds: 3,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Speech listen error: $e',
      );

      if (!mounted) return;

      setState(() {
        isListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not start microphone: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SPEECH RESULT
  // ============================================================

  void onSpeechResult(
    SpeechRecognitionResult result,
  ) {
    if (!mounted) return;

    setState(() {
      messageController.text =
          result.recognizedWords;

      messageController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: messageController.text.length,
        ),
      );
    });

    debugPrint(
      'Recognized speech: ${result.recognizedWords}',
    );

    if (result.finalResult) {
      setState(() {
        isListening = false;
      });
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final userMessage =
        messageController.text.trim();

    if (userMessage.isEmpty ||
        isLoading) {
      return;
    }

    // Stop microphone if currently listening
    if (isListening) {
      await speech.stop();

      if (mounted) {
        setState(() {
          isListening = false;
        });
      }
    }

    messageController.clear();

    setState(() {
      messages.add({
        'sender': 'user',
        'message': userMessage,
      });

      messages.add({
        'sender': 'ai',
        'message': '',
      });

      isLoading = true;
    });

    scrollToBottom();

    final aiMessageIndex =
        messages.length - 1;

    await askGeminiStream(
      userMessage,
      onTextChunk: (chunk) {
        if (!mounted) return;

        setState(() {
          messages[aiMessageIndex]['message'] =
              '${messages[aiMessageIndex]['message'] ?? ''}$chunk';
        });

        scrollToBottom();
      },
      onComplete: () {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        scrollToBottom();
      },
    );
  }

  // ============================================================
  // LANGUAGE INSTRUCTION
  // ============================================================

  String getLanguageInstruction() {
    if (widget.selectedLanguage == 'Hindi') {
      return '''
The selected language is Hindi.

IMPORTANT:
- Respond completely in Hindi.
- Use Devanagari script.
- Do NOT respond in English.
- Do NOT translate the answer into English.
- Use simple Hindi that Indian artisans can easily understand.
- English business words may be used only when necessary.
''';
    }

    if (widget.selectedLanguage == 'Telugu') {
      return '''
The selected language is Telugu.

IMPORTANT:
- Respond completely in Telugu.
- Use Telugu script.
- Do NOT respond in Hindi.
- Do NOT respond in English.
- Do NOT translate the answer into Hindi or English.
- Use simple Telugu that Indian artisans can easily understand.
- English business words may be used only when necessary.
''';
    }

    return '''
The selected language is English.

IMPORTANT:
- Respond completely in English.
- Use simple English.
- Do not unnecessarily translate the answer into another language.
''';
  }

  // ============================================================
  // GEMINI STREAMING
  // ============================================================

  Future<void> askGeminiStream(
    String userMessage, {
    required void Function(String chunk)
        onTextChunk,
    required VoidCallback onComplete,
  }) async {
    // ----------------------------------------------------------
    // PRODUCTS
    // ----------------------------------------------------------

    final productsInfo =
        savedProducts.isEmpty
            ? 'No products have been saved yet.'
            : savedProducts
                .map(
                  (product) =>
                      'Product: ${product.name}, '
                      'Category: ${product.category}, '
                      'Price: ${product.price}, '
                      'Description: ${product.description}',
                )
                .join('\n');

    // ----------------------------------------------------------
    // SALES
    // ----------------------------------------------------------

    final salesInfo =
        savedSales.isEmpty
            ? 'No sales have been recorded yet.'
            : savedSales
                .map(
                  (sale) =>
                      'Quantity sold: ${sale.quantity}, '
                      'Total sale amount: ₹${sale.totalAmount}',
                )
                .join('\n');

    // ----------------------------------------------------------
    // LANGUAGE
    // ----------------------------------------------------------

    final languageInstruction =
        getLanguageInstruction();

    // ----------------------------------------------------------
    // PROMPT
    // ----------------------------------------------------------

    final prompt = '''
You are ShilpSetu AI, a friendly business assistant
for Indian artisans and handicraft sellers.

You help artisans with:

- Product descriptions
- Product pricing
- Sales
- Marketing
- Finding buyers
- Business growth
- Social media marketing
- Customer communication

==================================================
LANGUAGE
==================================================

$languageInstruction

The user's selected language is:
${widget.selectedLanguage}

You MUST follow the selected language even if
the user's question contains English words.

==================================================
STYLE
==================================================

Use simple, friendly language.

Avoid complicated business terminology.

Use ₹ for prices.

Keep the response short and practical.

Response should normally be around 80-100 words.

==================================================
CURRENT PRODUCTS
==================================================

$productsInfo

==================================================
CURRENT SALES
==================================================

$salesInfo

==================================================
USER QUESTION
==================================================

$userMessage

==================================================
INSTRUCTION
==================================================

Give a direct and practical answer to the user's
question.

Remember: ALWAYS answer in the selected language:
${widget.selectedLanguage}
''';

    final client = http.Client();

    try {
      // --------------------------------------------------------
      // GEMINI REQUEST
      // --------------------------------------------------------

      final request = http.Request(
        'POST',
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/interactions',
        ),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'x-goog-api-key': geminiApiKey,
      });

      request.body = jsonEncode({
        'model': 'gemini-3.6-flash',
        'input': prompt,
        'stream': true,
      });

      debugPrint(
        '================ GEMINI STREAM ================',
      );

      debugPrint(
        'Selected language: ${widget.selectedLanguage}',
      );

      debugPrint(
        'Sending request...',
      );

      // --------------------------------------------------------
      // SEND REQUEST
      // --------------------------------------------------------

      final response =
          await client.send(request);

      debugPrint(
        'STATUS CODE: ${response.statusCode}',
      );

      // --------------------------------------------------------
      // ERROR
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        final errorBody =
            await response.stream.bytesToString();

        debugPrint(
          'GEMINI ERROR: $errorBody',
        );

        String errorMessage =
            'Gemini request failed. Status code: ${response.statusCode}';

        try {
          final errorData =
              jsonDecode(errorBody);

          final apiError =
              errorData['error']?['message'];

          if (apiError != null) {
            errorMessage =
                'Gemini error:\n$apiError';
          }
        } catch (_) {}

        onTextChunk(errorMessage);
        onComplete();

        client.close();

        return;
      }

      // --------------------------------------------------------
      // SSE STREAM
      // --------------------------------------------------------

      String pendingData = '';

      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(
                const LineSplitter(),
              )) {
        final trimmedLine =
            line.trim();

        // Ignore event name
        if (trimmedLine.startsWith('event:')) {
          continue;
        }

        // Process data
        if (trimmedLine.startsWith('data:')) {
          final data =
              trimmedLine.substring(5).trim();

          if (data == '[DONE]') {
            break;
          }

          pendingData = data;

          try {
            final json =
                jsonDecode(pendingData);

            final eventType =
                json['event_type'];

            // --------------------------------------------------
            // TEXT DELTA
            // --------------------------------------------------

            if (eventType ==
                'step.delta') {
              final delta =
                  json['delta'];

              if (delta != null &&
                  delta is Map &&
                  delta['type'] == 'text') {
                final text =
                    delta['text'];

                if (text != null &&
                    text
                        .toString()
                        .isNotEmpty) {
                  onTextChunk(
                    text.toString(),
                  );
                }
              }
            }

            // --------------------------------------------------
            // COMPLETED
            // --------------------------------------------------

            if (eventType ==
                'interaction.completed') {
              debugPrint(
                'Gemini interaction completed.',
              );
            }
          } catch (e) {
            debugPrint(
              'SSE JSON parse error: $e',
            );
          }

          pendingData = '';
        }
      }

      debugPrint(
        'Gemini stream finished.',
      );
    } catch (e) {
      debugPrint(
        'GEMINI STREAM ERROR: $e',
      );

      onTextChunk(
        '\n\nSorry, I could not connect to ShilpSetu AI.\n$e',
      );
    } finally {
      client.close();
      onComplete();
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============================================================
  // QUICK QUESTIONS
  // ============================================================

  void askQuickQuestion(
    String question,
  ) {
    if (isLoading) return;

    messageController.text =
        question;

    sendMessage();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    speech.stop();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor =
        Color(0xFFFFF8F0);

    const Color primaryColor =
        Color(0xFF8B4513);

    const Color darkTextColor =
        Color(0xFF5D2E0C);

    const Color lightTextColor =
        Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor:
          backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            primaryColor,

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor:
                  Colors.white,

              child: Icon(
                Icons.auto_awesome,
                color:
                    primaryColor,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'ShilpSetu AI',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  isListening
                      ? 'Listening... 🎙️'
                      : isLoading
                          ? 'Generating answer...'
                          : 'Language: ${widget.selectedLanguage}',

                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ======================================================
          // CHAT
          // ======================================================

          Expanded(
            child:
                ListView.builder(
              controller:
                  scrollController,

              padding:
                  const EdgeInsets.all(
                16,
              ),

              itemCount:
                  messages.length,

              itemBuilder:
                  (context, index) {
                final message =
                    messages[index];

                final isUser =
                    message['sender'] ==
                        'user';

                final messageText =
                    message['message'] ??
                        '';

                final isEmptyAiMessage =
                    !isUser &&
                    messageText.isEmpty &&
                    index ==
                        messages.length - 1 &&
                    isLoading;

                return Align(
                  alignment: isUser
                      ? Alignment
                          .centerRight
                      : Alignment
                          .centerLeft,

                  child:
                      Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 320,
                    ),

                    margin:
                        const EdgeInsets
                            .symmetric(
                      vertical: 6,
                    ),

                    padding:
                        const EdgeInsets.all(
                      15,
                    ),

                    decoration:
                        BoxDecoration(
                      color: isUser
                          ? primaryColor
                          : Colors.white,

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),

                      boxShadow: const [
                        BoxShadow(
                          color:
                              Colors.black12,
                          blurRadius:
                              5,
                          offset:
                              Offset(
                            0,
                            2,
                          ),
                        ),
                      ],
                    ),

                    child:
                        isEmptyAiMessage
                            ? const Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,

                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,

                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    'ShilpSetu is thinking...',
                                    style:
                                        TextStyle(
                                      color:
                                          lightTextColor,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                messageText,

                                style:
                                    TextStyle(
                                  fontSize:
                                      15,

                                  height:
                                      1.4,

                                  color: isUser
                                      ? Colors.white
                                      : darkTextColor,
                                ),
                              ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // QUICK QUESTIONS
          // ======================================================

          SizedBox(
            height: 45,

            child: ListView(
              scrollDirection:
                  Axis.horizontal,

              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
              ),

              children: [
                _quickButton(
                  'How should I price my product?',
                  () => askQuickQuestion(
                    'How should I price my product?',
                  ),
                ),

                _quickButton(
                  'How many products do I have?',
                  () => askQuickQuestion(
                    'How many products do I have?',
                  ),
                ),

                _quickButton(
                  'How are my sales?',
                  () => askQuickQuestion(
                    'How are my sales?',
                  ),
                ),

                _quickButton(
                  'How can I find buyers?',
                  () => askQuickQuestion(
                    'How can I find buyers?',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          // ======================================================
          // INPUT
          // ======================================================

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                12,
                5,
                12,
                12,
              ),

              child: Row(
                children: [
                  // ==================================================
                  // TEXT FIELD
                  // ==================================================

                  Expanded(
                    child: TextField(
                      controller:
                          messageController,

                      textInputAction:
                          TextInputAction
                              .send,

                      onSubmitted:
                          (_) =>
                              sendMessage(),

                      decoration:
                          InputDecoration(
                        hintText:
                            isListening
                                ? 'Listening...'
                                : 'Ask ShilpSetu...',

                        filled: true,

                        fillColor:
                            Colors.white,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            25,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              18,
                          vertical:
                              14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // ==================================================
                  // MICROPHONE
                  // ==================================================

                  Container(
                    decoration:
                        BoxDecoration(
                      color: isListening
                          ? Colors.red
                          : primaryColor,

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        IconButton(
                      onPressed:
                          isLoading
                              ? null
                              : toggleListening,

                      icon: Icon(
                        isListening
                            ? Icons.mic
                            : Icons.mic_none,

                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  // ==================================================
                  // SEND
                  // ==================================================

                  Container(
                    decoration:
                        const BoxDecoration(
                      color:
                          primaryColor,

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        IconButton(
                      onPressed:
                          isLoading
                              ? null
                              : sendMessage,

                      icon:
                          const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK QUESTION BUTTON
  // ============================================================

  Widget _quickButton(
    String text,
    VoidCallback onTap,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: ActionChip(
        label: Text(text),

        onPressed:
            isLoading
                ? null
                : onTap,

        backgroundColor:
            const Color(
          0xFFFFE4CC,
        ),

        labelStyle:
            const TextStyle(
          color:
              Color(0xFF5D2E0C),
          fontSize:
              12,
        ),
      ),
    );
  }
}