import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ai_agent_mobile_app/theme/theme.dart';

class BottomNavigationIndicator extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const BottomNavigationIndicator({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<BottomNavigationIndicator> createState() =>
      _BottomNavigationIndicatorState();
}

class _BottomNavigationIndicatorState extends State<BottomNavigationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDragging = false;
  double _dragOffset = 0.0;
  final int _totalTabs = 4;

  // 图标定义
  static const List<Map<String, dynamic>> _tabIcons = [
    {
      'id': 'chat',
      'name': '聊天',
      'svg': '''
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M20 2H4C2.9 2 2 2.9 2 4V22L6 18H20C21.1 18 22 17.1 22 16V4C22 2.9 21.1 2 20 2Z" 
                fill="currentColor"/>
          <circle cx="8" cy="10" r="1" fill="white"/>
          <circle cx="12" cy="10" r="1" fill="white"/>
          <circle cx="16" cy="10" r="1" fill="white"/>
          <circle cx="12" cy="6" r="0.5" fill="white">
            <animate attributeName="opacity" values="1;0.3;1" dur="2s" repeatCount="indefinite"/>
          </circle>
        </svg>
      ''',
      'color': AppColors.primary,
    },
    {
      'id': 'music',
      'name': '音乐',
      'svg': '''
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 3V12.26C11.5 12.09 11 12 10.5 12C7.46 12 5 14.46 5 17.5C5 20.54 7.46 23 10.5 23C13.54 23 16 20.54 16 17.5V7H20V3H12Z" 
                fill="currentColor"/>
          <circle cx="10.5" cy="17.5" r="1.5" fill="white"/>
          <path d="M8 17.5C8 18.33 8.67 19 9.5 19C10.33 19 11 18.33 11 17.5" 
                stroke="white" stroke-width="1" fill="none">
            <animate attributeName="stroke-dashoffset" values="0;10;0" dur="1.5s" repeatCount="indefinite"/>
          </path>
        </svg>
      ''',
      'color': AppColors.primary,
    },
    {
      'id': 'image',
      'name': '图片',
      'svg': '''
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect x="3" y="3" width="18" height="18" rx="2" fill="currentColor"/>
          <circle cx="8.5" cy="8.5" r="2" fill="white"/>
          <path d="M21 15L16 10L5 21" stroke="white" stroke-width="1.5" fill="none"/>
          <path d="M16 14L19 17V21" stroke="white" stroke-width="1" fill="none">
            <animate attributeName="stroke-dashoffset" values="0;8;0" dur="2s" repeatCount="indefinite"/>
          </path>
        </svg>
      ''',
      'color': AppColors.primary,
    },
    {
      'id': 'settings',
      'name': '设置',
      'svg': '''
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 15C13.6569 15 15 13.6569 15 12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12C9 13.6569 10.3431 15 12 15Z" 
                fill="white"/>
          <path d="M19.4 15C19.2 15 19 15 18.9 14.9L17.6 14.2C17.4 14.1 17.2 14.1 17 14.2L15.6 15.1C15.4 15.2 15.2 15.4 15.1 15.6L14.9 17.2C14.9 17.5 15.1 17.7 15.4 17.8L16.8 18.2C18.3 17.6 19.4 16.5 19.4 15Z" 
                fill="currentColor"/>
          <path d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C12.55 22 13 21.55 13 21V18.5C13 17.67 13.67 17 14.5 17H18C18.55 17 19 16.55 19 16V12C19 6.48 14.52 2 9 2C5.13 2 2 5.13 2 9V11" 
                stroke="currentColor" stroke-width="2" fill="none">
            <animate attributeName="stroke-dashoffset" values="0;40;0" dur="3s" repeatCount="indefinite"/>
          </path>
        </svg>
      ''',
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _animationController.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = details.localPosition.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    // 计算目标页面
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _totalTabs;
    final targetIndex =
        (_dragOffset / tabWidth).clamp(0, _totalTabs - 1).floor();

    if (targetIndex != widget.currentIndex) {
      widget.onIndexChanged(targetIndex);
    }

    // 延迟500ms后渐隐
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  void _onTap(int index) {
    if (index != widget.currentIndex) {
      widget.onIndexChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _totalTabs;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            // 背景指示器
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: widget.currentIndex * tabWidth,
              child: Container(
                width: tabWidth,
                height: 60,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _isDragging ? 38 : 18,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _tabIcons[widget.currentIndex]['color'],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // 图标层
            Row(
              children: List.generate(_totalTabs, (index) {
                final isSelected = index == widget.currentIndex;
                final tabData = _tabIcons[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(index),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: _buildIconIndicator(isSelected, tabData),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(bool isSelected, Map<String, dynamic> tabData) {
    return Container(
      width: isSelected ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isSelected ? tabData['color'] : Colors.white54,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildIconIndicator(bool isSelected, Map<String, dynamic> tabData) {
    final size = isSelected ? 38.0 : 28.0;
    final opacity = isSelected ? 1.0 : 0.55;
    final glowSize = isSelected ? 12.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 辉光效果
          if (isSelected)
            Container(
              width: size + glowSize * 2,
              height: size + glowSize * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (tabData['color'] as Color).withOpacity(0.3),
                    blurRadius: glowSize,
                    spreadRadius: glowSize / 2,
                  ),
                ],
              ),
            ),

          // 图标容器
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tabData['color'],
                width: 1.4,
              ),
              color: Colors.transparent,
            ),
            child: Center(
              child: Opacity(
                opacity: opacity,
                child: SvgPicture.string(
                  tabData['svg'],
                  width: size * 0.6,
                  height: size * 0.6,
                  colorFilter: ColorFilter.mode(
                    tabData['color'],
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
