import 'package:flutter/material.dart';
import 'package:gym_project_app/models/gym.dart';
import 'package:gym_project_app/services/payment_service.dart';
import 'package:flutter/services.dart';

class GymDetailPage extends StatelessWidget {
  final Gym gym;
  final PaymentService _paymentService = PaymentService();

  GymDetailPage({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gym.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endereço: ${gym.description ?? "Não disponível"}'),
            Text('Distância: ${gym.distance.toStringAsFixed(2)} km'),
            Text('Preço: R\$ ${gym.price.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Pagar com Pix'),
              onPressed: () async {
                try {
                  final pixCode = await _paymentService.generatePixCode(gym.price);
                  _showPixDialog(context, pixCode);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao gerar código Pix')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPixDialog(BuildContext context, String pixCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Código Pix Gerado'),
          content: SelectableText(pixCode),
          actions: <Widget>[
            TextButton(
              child: const Text('Copiar'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: pixCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código Pix copiado para a área de transferência')),
                );
              },
            ),
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}