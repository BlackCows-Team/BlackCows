class AnalysisTab {
  final String id;
  final String label;
  final String description;
  final String icon;
  final Color color;
  final List<String> requiredFields;
  final bool isPremium;
  final String? subtitle;

  const AnalysisTab({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredFields,
    this.isPremium = false,
    this.subtitle,
  });
}

const List<AnalysisTab> analysisTabs = [
  AnalysisTab(
    id: 'milk_yield',
    label: '착유량 예측',
    description: '착유 횟수, 사료 섭취량, 환경 온도 등을 분석하여 향후 착유량을 정확히 예측합니다',
    icon: '🥛',
    color: Color(0xFF4CAF50),
    requiredFields: ['착유횟수', '사료섭취량', '온도', '유지방비율', '전도율', '유단백비율'],
  ),
  AnalysisTab(
    id: 'mastitis_risk',
    label: '유방염 위험도',
    description: '체세포수 데이터 또는 다양한 생체 지표를 통해 유방염 위험도를 단계별로 예측합니다',
    icon: '⚠️',
    color: Color(0xFFFF9800),
    requiredFields: ['체세포수'],
    subtitle: '체세포수 유무에 따른 2가지 분석 모드',
  ),
  AnalysisTab(
    id: 'milk_quality',
    label: '유성분 품질 예측',
    description: '사료 섭취량, 환경 요인, 착유량 등을 종합하여 우유의 성분 품질을 예측합니다',
    icon: '🔬',
    color: Color(0xFF2196F3),
    requiredFields: ['사료섭취량', '온도', '착유량', '산차수', '전도율', '질병이력'],
  ),
  AnalysisTab(
    id: 'feed_efficiency',
    label: '사료 효율 분석',
    description: '사료 대비 착유량 효율을 분석하여 경제적인 사료 급여 방안을 제시합니다',
    icon: '📊',
    color: Color(0xFF9C27B0),
    requiredFields: ['사료섭취량', '착유량', '체중', '활동량', '산차수', '체형점수'],
  ),
  AnalysisTab(
    id: 'calving_prediction',
    label: '분만 예측',
    description: '수정일, 공태일수, 건강 상태 등을 분석하여 분만 시점을 정확히 예측합니다',
    icon: '🐄',
    color: Color(0xFF795548),
    requiredFields: ['수정일', '공태일수', '산차수', '이전분만일', '수정방법', '유방염이력'],
  ),
  AnalysisTab(
    id: 'breeding_timing',
    label: '교배 타이밍 추천',
    description: '체온, 활동량, 발정 주기를 분석하여 최적의 수정 시점을 추천합니다',
    icon: '❤️',
    color: Color(0xFFE91E63),
    requiredFields: ['체온', '활동량', '발정주기', '마지막분만일', '공태일수', '산차수'],
  ),
  AnalysisTab(
    id: 'lumpy_skin_detection',
    label: '럼피스킨병 AI 진단',
    description: '소 피부 이미지를 AI로 분석하여 럼피스킨병을 조기 진단하고 감염 부위를 정확히 탐지합니다',
    icon: '🔍',
    color: Color(0xFFFF5722),
    requiredFields: ['소 피부 이미지'],
    isPremium: true,
  ),
];
