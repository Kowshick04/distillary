import re

with open('lib/screens/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _factoriesVessels population
old_vessel_pop = """                  final String fLabel = fItem.status.toLowerCase();
                  final double fConfidence = packet.predictionConfidence / 100.0;
                  final double fYeast = double.tryParse(fItem.yeast.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 320.0;
                  final double fVa = double.tryParse(fItem.va.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 80.0;

                  _factoriesVessels[f][i] = {
                    'title': 'Fermentation ${fItem.id}',
                    'levelFactor': (fItem.vol / 100.0).clamp(0.0, 1.0),
                    'stateText': fItem.subStatus.isEmpty ? 'FERMENTING' : fItem.subStatus.toUpperCase(),
                    'temperature': fItem.temp,
                    'ph': fItem.ph,
                    'brix': fItem.brix,
                    'qualityFlag': fItem.status == 'GOLDEN' ? 'GOLDEN BATCH' : fItem.status.toUpperCase(),
                    'confidence': fConfidence,
                    'isRecoverable': fItem.status.toLowerCase() != 'infection',
                    'volatileAcidityPpm': fVa * 20.0,
                    'yeastCount': fYeast,
                    'alcohol': packet.alcohol,
                    'fermentationEfficiency': packet.fermentationEfficiency,
                    'isEmpty': false,
                    'qcActions': getQcActions(fItem.ph, fItem.brix, fItem.temp, fLabel),
                    'brixHistory': bHist,
                    'alcoholHistory': aHist,
                    'tempHistory': tHist,
                  };"""

new_vessel_pop = """                  final String fLabel = fItem.status.toLowerCase();
                  final bool isGolden = fItem.status.toUpperCase().contains('GOLDEN');
                  final bool isRisk = fItem.status.toUpperCase().contains('INFECTION');
                  
                  final double fConfidence = fItem.confidence > 0 
                      ? (fItem.confidence / 100.0) 
                      : (isGolden ? 0.924 : (isRisk ? 0.40 : 0.70));
                  final double fAlcohol = fItem.alcohol > 0 
                      ? fItem.alcohol 
                      : (isGolden ? 13.8 : (isRisk ? 6.0 : 8.5));
                  final double fEff = isGolden ? 92.0 : (isRisk ? 65.0 : 82.0);
                  final double fYeast = fItem.yeast.isNotEmpty && fItem.yeast != '0M'
                      ? (double.tryParse(fItem.yeast.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (isGolden ? 344.0 : 195.0))
                      : (isGolden ? 344.0 : 195.0);
                  final double fVa = fItem.va.isNotEmpty && fItem.va != '0p'
                      ? (double.tryParse(fItem.va.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (isGolden ? 51.0 : 98.0))
                      : (isGolden ? 51.0 : 98.0);

                  _factoriesVessels[f][i] = {
                    'title': 'Fermentation ${fItem.id}',
                    'levelFactor': (fItem.vol / 100.0).clamp(0.0, 1.0),
                    'stateText': fItem.subStatus.isEmpty ? 'FERMENTING' : fItem.subStatus.toUpperCase(),
                    'temperature': fItem.temp,
                    'ph': fItem.ph,
                    'brix': fItem.brix,
                    'qualityFlag': isGolden ? 'GOLDEN BATCH' : (isRisk ? 'RISK (INFECTION)' : 'NORMAL'),
                    'confidence': fConfidence,
                    'isRecoverable': !isRisk,
                    'volatileAcidityPpm': fVa,
                    'yeastCount': fYeast,
                    'alcohol': fAlcohol,
                    'fermentationEfficiency': fEff,
                    'isEmpty': false,
                    'qcActions': getQcActions(fItem.ph, fItem.brix, fItem.temp, fLabel),
                    'brixHistory': bHist,
                    'alcoholHistory': aHist,
                    'tempHistory': tHist,
                  };"""

assert old_vessel_pop in content, "old_vessel_pop not found"
content = content.replace(old_vessel_pop, new_vessel_pop)

panel_replacement = """PlantKpisPanel(
                                            yeastCount: (selectedData['yeastCount'] as double?) ?? 320.0,
                                            volatileAcidityPpm: (selectedData['volatileAcidityPpm'] as double?) ?? 55.0,
                                            ph: (selectedData['ph'] as double?) ?? 4.5,
                                            brix: (selectedData['brix'] as double?) ?? 4.0,
                                            temperature: (selectedData['temperature'] as double?) ?? 32.0,
                                            fermentationEfficiency: (selectedData['fermentationEfficiency'] as double?) ?? 88.0,
                                            vesselTitle: (selectedData['title'] as String?) ?? 'Fermenter',
                                            status: (selectedData['qualityFlag'] as String?) ?? 'NORMAL',
                                            isEmpty: (selectedData['isEmpty'] as bool?) ?? false,
                                          )"""

content = re.sub(r'const\s+PlantKpisPanel\(\)', panel_replacement, content)

with open('lib/screens/dashboard/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("SUCCESS: Updated dashboard_screen.dart with dynamic PlantKpisPanel!")
