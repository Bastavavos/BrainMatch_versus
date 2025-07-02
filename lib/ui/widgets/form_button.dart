import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const FormButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary.withOpacity(0.1), // bouton clair
            foregroundColor: colorScheme.primary, // couleur du texte et icône
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 3,
          ),
          icon: Icon(icon),
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.primary,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class FormButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback? onPressed;
//
//   const FormButton({super.key,
//     required this.label,
//     required this.icon,
//     required this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: 200,
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.deepPurple.shade100,
//             foregroundColor: Colors.black,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24),
//             ),
//             elevation: 3,
//           ),
//           icon: Icon(icon),
//           label: Text(label),
//           onPressed: onPressed,
//         ),
//       ),
//     );
//   }
// }