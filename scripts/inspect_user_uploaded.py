import os
import json
import openpyxl

with open("assets/model/rf_model.json", "r") as f:
    rf_data = json.load(f)

feature_names = rf_data["feature_names"]

def predict(inputs):
    estimators = rf_data["estimators"]
    classes = rf_data["classes"]
    features = [inputs.get(name, 0.0) for name in feature_names]
    class_probs = [0.0] * len(classes)
    for est in estimators:
        left = est["children_left"]
        right = est["children_right"]
        feature = est["feature"]
        threshold = est["threshold"]
        value_dist = est["value"]
        curr = 0
        while left[curr] != -1 and right[curr] != -1:
            sf = feature[curr]
            val = features[sf]
            thresh = threshold[curr]
            if val <= thresh: curr = left[curr]
            else: curr = right[curr]
        counts = value_dist[curr][0]
        tot = sum(counts)
        if tot > 0:
            for i, c in enumerate(counts):
                class_probs[i] += (c / tot) / len(estimators)
    best_idx = 0
    max_p = -1.0
    for i, p in enumerate(class_probs):
        if p > max_p: max_p = p; best_idx = i
    cls_int = classes[best_idx]
    label = 'normal'
    if cls_int == 0: label = 'low_alcohol'
    elif cls_int == 2: label = 'golden'
    return label, max_p * 100.0, class_probs

scratch_dir = "C:/Users/Admin B/.gemini/antigravity-ide/brain/c66be34d-0c41-411a-bdf3-0faf8b47e70e/scratch"
for fn in ["Nellikuppam_120KLPD_Normal_vs_Golden.xlsx", "Sivagangai_64KLPD_Normal_vs_Golden.xlsx"]:
    path = os.path.join(scratch_dir, fn)
    if not os.path.exists(path):
        print(f"File not found: {path}")
        continue
    wb = openpyxl.load_workbook(path, data_only=True)
    sheet = wb.active
    print(f"\n==================== {fn} (Total rows: {sheet.max_row}) ====================")
    
    # Print the last 10 rows
    for r in range(max(7, sheet.max_row - 8), sheet.max_row + 1):
        f_num = sheet.cell(row=r, column=5).value
        feed_h = sheet.cell(row=r, column=9).value
        ret_h = sheet.cell(row=r, column=10).value
        setup_sg = sheet.cell(row=r, column=29).value
        final_sg = sheet.cell(row=r, column=30).value
        setup_alc = sheet.cell(row=r, column=32).value
        final_alc = sheet.cell(row=r, column=33).value
        setup_ph = sheet.cell(row=r, column=36).value
        final_ph = sheet.cell(row=r, column=37).value
        
        vals = {
            "feeding_hours": float(feed_h or 18.5) if feed_h is not None else 18.5,
            "retention_hours": float(ret_h or 48.0) if ret_h is not None else 48.0,
            "setup_sg": float(setup_sg or 1.085) if setup_sg is not None else 1.085,
            "final_sg": float(final_sg or 1.010) if final_sg is not None else 1.010,
            "sg_diff": abs(float(setup_sg or 1.085) - float(final_sg or 1.010)) if setup_sg is not None and final_sg is not None else 0.075,
            "setup_alc": float(setup_alc or 0.0) if setup_alc is not None else 0.0,
            "final_alc": float(final_alc or 11.5) if final_alc is not None else 11.5,
            "setup_ph": float(setup_ph or 4.5) if setup_ph is not None else 4.5,
            "final_ph": float(final_ph or 4.48) if final_ph is not None else 4.48,
        }
        lbl, conf, probs = predict(vals)
        print(f"Row {r:3d}: Fermenter={f_num} | FeedH={feed_h} | RetH={ret_h} | SG={final_sg} | Alc={final_alc} | pH={final_ph} -> Pred={lbl.upper()} ({conf:.1f}%) [P_low={probs[0]:.2f}, P_norm={probs[1]:.2f}, P_gold={probs[2]:.2f}]")
