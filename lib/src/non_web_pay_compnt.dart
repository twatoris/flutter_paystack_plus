//flutter_paystack_plus/lib/src/non_web_pay_compnt.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

// Custom glassmorphic glass widgets
import 'glass/decorations.dart';
import 'glass/glass_widgets.dart';

class PaystackPayNow extends StatefulWidget {
  final String secretKey;
  final String reference;
  final String callbackUrl;
  final String currency;
  final String email;
  final String amount;
  final String? plan;
  final Map<String, dynamic>? metadata;
  final List<String>? paymentChannel;
  final VoidCallback transactionCompleted;
  final VoidCallback transactionNotCompleted;
  final Color? tintColor;

  const PaystackPayNow({
    super.key,
    required this.secretKey,
    required this.email,
    required this.reference,
    required this.currency,
    required this.amount,
    required this.callbackUrl,
    required this.transactionCompleted,
    required this.transactionNotCompleted,
    this.metadata,
    this.plan,
    this.paymentChannel,
    this.tintColor,
  });

  @override
  State<PaystackPayNow> createState() => _PaystackPayNowState();
}

class _PaystackPayNowState extends State<PaystackPayNow> with SingleTickerProviderStateMixin {
  late Future<PaystackRequestResponse> payment;
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    payment = _makePaymentRequest();

    // Pulse animation for loading states
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Enterprise-grade HTTP request with comprehensive error handling
  Future<PaystackRequestResponse> _makePaymentRequest() async {
    http.Response response;

    try {
      final Map<String, dynamic> requestBody = {
        "email": widget.email,
        "amount": widget.amount,
        "reference": widget.reference,
        "currency": widget.currency,
        if (widget.plan != null) "plan": widget.plan,
        if (widget.metadata != null) "metadata": widget.metadata,
        "callback_url": widget.callbackUrl,
        if (widget.paymentChannel != null) "channels": widget.paymentChannel,
      };

      // Add cancel metadata for better user experience
      final Map<String, dynamic> finalMetadata = {
        "cancel_action": "cancelurl.com",
        ...?widget.metadata,
      };
      requestBody["metadata"] = finalMetadata;

      response = await http
          .post(
            Uri.parse('https://api.paystack.co/transaction/initialize'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.secretKey}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (e) {
      _handleRequestError('Network error: ${e.message}');
      rethrow;
    } on TimeoutException catch (_) {
      _handleRequestError('Request timeout. Please check your connection');
      rethrow;
    } on Exception catch (e) {
      _handleRequestError('Payment initialization failed: ${e.toString()}');
      rethrow;
    }

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        return PaystackRequestResponse.fromJson(jsonBody);
      } catch (e) {
        throw const FormatException('Invalid response format from PayStack');
      }
    } else {
      final errorMessage = _parseErrorResponse(response);
      throw HttpException('Payment failed: $errorMessage', response.statusCode);
    }
  }

  void _handleRequestError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  String _parseErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Unknown error';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }

  WebViewController _buildController(String authUrl) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;

            // Handle payment completion/cancellation
            if (url.contains('cancelurl.com') ||
                url.contains('paystack.co/close') ||
                url.contains(widget.callbackUrl)) {
              await _verifyAndCloseTransaction(widget.reference);
              if (mounted) {
                Navigator.of(context).pop();
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'WebView error: ${error.description}';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(authUrl));

    return controller;
  }

  /// Enterprise-grade transaction verification
  Future<void> _verifyAndCloseTransaction(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.secretKey}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data = decodedBody['data'] as Map<String, dynamic>;
        final String gatewayResponse = data['gateway_response']?.toString() ?? '';

        if (gatewayResponse == 'Approved' || gatewayResponse == 'Successful') {
          widget.transactionCompleted();
        } else {
          widget.transactionNotCompleted();
        }
      } else {
        widget.transactionNotCompleted();
      }
    } on Exception catch (_) {
      widget.transactionNotCompleted();
    }
  }

  Color get _effectiveTintColor => widget.tintColor ?? const Color(0xFF5957B0);

  String get _formattedAmount {
    try {
      final double amountInUnits = double.parse(widget.amount) / 100;
      return '${amountInUnits.toStringAsFixed(2)} ${widget.currency.toUpperCase()}';
    } catch (_) {
      return '${widget.amount} ${widget.currency.toUpperCase()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Premium gradient background with subtle animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _effectiveTintColor.withValues(alpha: 0.04 * _pulseAnimation.value),
                        _effectiveTintColor.withValues(alpha: 0.02 * _pulseAnimation.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Premium glass app bar with security indicator
                GlassAppBar(
                  title: 'Secure Payment',
                  tintColor: _effectiveTintColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Cancel payment',
                    onPressed: () => _showExitConfirmation(context),
                  ),
                  actions: [
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(_effectiveTintColor),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: Colors.green[400],
                          size: 24,
                        ),
                      ),
                  ],
                ),

                // Security badge banner
                _buildSecurityBadge(),

                Expanded(
                  child: FutureBuilder<PaystackRequestResponse>(
                    future: payment,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<PaystackRequestResponse> snapshot,
                    ) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }

                      // Error state
                      if (snapshot.hasError || _hasError) {
                        return _buildErrorState(
                          snapshot.error?.toString() ?? _errorMessage,
                        );
                      }

                      // Payment ready state
                      if (snapshot.hasData && snapshot.data!.status) {
                        return _buildPaymentWebView(snapshot.data!);
                      }

                      // Fallback state
                      return _buildFallbackState();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GlassCard(
        intensity: GlassIntensity.subtle,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 16,
              color: _effectiveTintColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '256-bit SSL Encrypted • PCI DSS Compliant',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GlassCard(
              intensity: GlassIntensity.strong,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium loading indicator
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _effectiveTintColor.withValues(alpha: 0.2),
                          _effectiveTintColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(_effectiveTintColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Initializing Secure Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _effectiveTintColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connecting to PayStack Gateway',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Encrypted Connection',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? errorDetails) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          intensity: GlassIntensity.medium,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon with gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red[300]!,
                      Colors.red[400]!,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                intensity: GlassIntensity.subtle,
                tintColor: Colors.red.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorDetails ?? 'An unexpected error occurred',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GlassButton(
                text: 'Retry Payment',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  setState(() {
                    payment = _makePaymentRequest();
                    _hasError = false;
                    _errorMessage = null;
                  });
                },
                style: GlassButtonStyle.solid,
                tintColor: _effectiveTintColor,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              GlassButton(
                text: 'Cancel Payment',
                icon: Icons.close_rounded,
                onPressed: () => Navigator.of(context).pop(),
                style: GlassButtonStyle.outlined,
                tintColor: Colors.grey[700]!,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Text(
                'Need help? Contact support',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentWebView(PaystackRequestResponse response) {
    _controller ??= _buildController(response.authUrl);

    return Stack(
      children: [
        // Main WebView
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: WebViewWidget(
              key: ValueKey<String>('paystack-webview-${response.reference}'),
              controller: _controller!,
            ),
          ),
        ),

        // Loading overlay with premium animation
        if (_isLoading) _buildWebViewLoadingOverlay(),

        // Payment info overlay (bottom)
        _buildPaymentInfoOverlay(response),
      ],
    );
  }

  Widget _buildWebViewLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GlassCard(
                intensity: GlassIntensity.strong,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(_effectiveTintColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Processing Payment...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _effectiveTintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please do not close this window',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: Colors.green[300],
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Secure Transaction',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentInfoOverlay(PaystackRequestResponse response) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: GlassCard(
        intensity: GlassIntensity.strong,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _effectiveTintColor.withValues(alpha: 0.2),
                        _effectiveTintColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: _effectiveTintColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Payment Gateway',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _effectiveTintColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PayStack • ${widget.currency.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formattedAmount,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _effectiveTintColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ref: ${response.reference}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackState() {
    return Center(
      child: GlassCard(
        intensity: GlassIntensity.medium,
        padding: const EdgeInsets.all(40),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_effectiveTintColor),
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          intensity: GlassIntensity.strong,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'Cancel Payment?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel this transaction?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Continue',
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: GlassButtonStyle.outlined,
                      tintColor: _effectiveTintColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: GlassButtonStyle.solid,
                      tintColor: Colors.red[400]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Use the original context only if still mounted
    if (shouldExit == true) {
      if (!mounted) return;
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }
}

/// PayStack API Response Model
class PaystackRequestResponse {
  final bool status;
  final String authUrl;
  final String reference;

  const PaystackRequestResponse({
    required this.authUrl,
    required this.status,
    required this.reference,
  });

  factory PaystackRequestResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? {};

    return PaystackRequestResponse(
      status: json['status'] as bool? ?? false,
      authUrl: data['authorization_url'] as String? ?? '',
      reference: data['reference'] as String? ?? '',
    );
  }
}

/// Custom HTTP Exception with status code
class HttpException implements Exception {
  final String message;
  final int statusCode;

  const HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HTTP $statusCode: $message';
}
