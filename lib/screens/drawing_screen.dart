import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class DrawingScreen extends StatefulWidget {
  final String? drawingData;

  const DrawingScreen({super.key, this.drawingData});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late SignatureController _controller;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: _strokeWidth,
      penColor: _selectedColor,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
  // Preserve the old strokes if desired:
  final points = _controller.points;
  _controller.dispose();

  _controller = SignatureController(
    penStrokeWidth: _strokeWidth,
    penColor: _selectedColor,
    exportBackgroundColor: Colors.white,
  )..points = points; // restore existing drawing
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              _controller.undo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              _controller.redo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Stroke Width:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 10.0,
                  onChanged: (value) {
  setState(() {
    _strokeWidth = value;
    _updateController();
  });
},

                ),
              ),
              Text(_strokeWidth.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Color:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  children: [
                    Colors.black,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.brown,
                    Colors.pink,
                  ].map((color) => _buildColorButton(color)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
  setState(() {
    _selectedColor = color;
    _updateController();
  });
},

      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha:0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDrawing() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvas is empty')),
      );
      return;
    }

    final signature = await _controller.toPngBytes();
    if (signature != null && mounted) {
      Navigator.pop(context, signature.toString());
    }
  }
}
