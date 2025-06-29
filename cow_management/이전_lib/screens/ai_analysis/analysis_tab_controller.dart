class AnalysisTab {
  final String id;
  final String label;
  final String description;

  const AnalysisTab({
    required this.id,
    required this.label,
    required this.description,
  });
}

const List<AnalysisTab> analysisTabs = [
  AnalysisTab(
    id: 'milk_yield',
    label: '착유량 예측',
    description: '하루 평균 착유량을 예측해요',
  ),
  AnalysisTab(
    id: 'milk_quality',
    label: '우유 품질 예측',
    description: '우유의 품질(지방, 단백질 등)을 예측해요',
  ),
  AnalysisTab(
    id: 'breeding',
    label: '번식 타이밍 추천',
    description: '교배에 가장 적절한 시기를 추천해요',
  ),
  AnalysisTab(
    id: 'mastitis',
    label: '유방염 예측',
    description: '유방염 위험도를 미리 예측해요',
  ),
];
