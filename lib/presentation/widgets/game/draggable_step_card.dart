import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/recipe_step.dart';

class DraggableStepCard extends StatefulWidget {
  final RecipeStep step;
  final int index;
  final bool isCorrect;
  final bool showCorrectness;
  final String? hint;
  
  const DraggableStepCard({
    Key? key,
    required this.step,
    required this.index,
    this.isCorrect = false,
    this.showCorrectness = false,
    this.hint,
  }) : super(key: key);

  @override
  State<DraggableStepCard> createState() => _DraggableStepCardState();
}

class _DraggableStepCardState extends State<DraggableStepCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onDragStarted() {
    setState(() => _isDragging = true);
    _animationController.forward();
  }
  
  void _onDragEnded() {
    setState(() => _isDragging = false);
    _animationController.reverse();
  }
  
  Color _getCardColor() {
    if (!widget.showCorrectness) {
      return Colors.white;
    }
    
    return widget.isCorrect 
        ? Colors.green[50]! 
        : Colors.red[50]!;
  }
  
  Color _getBorderColor() {
    if (!widget.showCorrectness) {
      return AppColors.divider;
    }
    
    return widget.isCorrect 
        ? Colors.green[400]! 
        : Colors.red[400]!;
  }
  
  Widget _buildStepNumber() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getNumberBackgroundColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getNumberBorderColor(),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${widget.index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getNumberTextColor(),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  Color _getNumberBackgroundColor() {
    if (widget.showCorrectness) {
      return widget.isCorrect ? Colors.green[100]! : Colors.red[100]!;
    }
    return AppColors.primaryColor.withOpacity(0.1);
  }
  
  Color _getNumberBorderColor() {
    if (widget.showCorrectness) {
      return widget.isCorrect ? Colors.green[400]! : Colors.red[400]!;
    }
    return AppColors.primaryColor;
  }
  
  Color _getNumberTextColor() {
    if (widget.showCorrectness) {
      return widget.isCorrect ? Colors.green[700]! : Colors.red[700]!;
    }
    return AppColors.primaryColor;
  }
  
  Widget _buildCorrectOrderBadge() {
    if (!widget.showCorrectness) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.isCorrect ? Colors.green[400] : Colors.red[400],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.isCorrect ? '정답' : '${widget.step.order}번째',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildHintSection() {
    if (widget.hint == null || widget.hint!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: Colors.amber[700],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.hint!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeEstimate() {
    if (widget.step.timeEstimate == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.step.timeEstimate}분',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            key: widget.key,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Material(
              color: _getCardColor(),
              borderRadius: BorderRadius.circular(12),
              elevation: _elevationAnimation.value,
              shadowColor: AppColors.cardShadow,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: widget.showCorrectness ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle area - only this area triggers drag
                          ReorderableDragStartListener(
                            index: widget.index,
                            child: GestureDetector(
                              onTapDown: (_) => _onDragStarted(),
                              onTapUp: (_) => _onDragEnded(),
                              onTapCancel: _onDragEnded,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isDragging 
                                      ? AppColors.primaryColor.withOpacity(0.2)
                                      : AppColors.textSecondary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isDragging 
                                        ? AppColors.primaryColor
                                        : AppColors.textSecondary.withOpacity(0.3),
                                    width: _isDragging ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.pan_tool,
                                  color: _isDragging 
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Step number
                          _buildStepNumber(),
                          const SizedBox(width: 12),
                          
                          // Step content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.step.description,
                                        style: AppTextStyles.cardContent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCorrectOrderBadge(),
                                  ],
                                ),
                                
                                // Time estimate and tip row
                                if (widget.step.timeEstimate != null || widget.step.tip != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        _buildTimeEstimate(),
                                        if (widget.step.timeEstimate != null && widget.step.tip != null)
                                          const SizedBox(width: 8),
                                        if (widget.step.tip != null)
                                          Expanded(
                                            child: Text(
                                              widget.step.tip!,
                                              style: AppTextStyles.cardSubtitle.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Hint section
                      _buildHintSection(),
                      
                      // Key point section
                      if (widget.step.keyPoint != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                size: 16,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.step.keyPoint!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}