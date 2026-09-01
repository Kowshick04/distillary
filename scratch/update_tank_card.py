with open('lib/screens/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = [
    "                                                   yeastCount: (data['yeastCount'] as double?) ?? 320.0,\n",
    "                                                   volatileAcidity: (data['volatileAcidityPpm'] as double?) ?? 55.0,\n",
    "                                                   qcAction: ((data['qcActions'] as List?)?.isNotEmpty ?? false) ? (data['qcActions'] as List).first.action : 'Profile Optimal',\n",
]

for idx, line in enumerate(lines):
    if "final data = _factoriesVessels[opIndex][index];" in line:
        for k in range(idx, idx + 20):
            if "qualityFlag: data['qualityFlag'] as String," in lines[k]:
                lines[k+1:k+1] = new_lines
                print(f"Inserted at line {k+1}")
                break
        break

with open('lib/screens/dashboard/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("SUCCESS: Updated operator LiquidTankCard props!")
