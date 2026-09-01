import json

with open("assets/model/rf_model.json", "r") as f:
    rf_data = json.load(f)

# Classes: 0: low_alcohol, 1: normal, 2: golden
print("Classes:", rf_data["classes"])
print("Features:", rf_data["feature_names"])

# Let's test a sweep of final_alc, retention_hours, sg_diff, feeding_hours
for alc in [6.0, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5]:
    for ret in [15.0, 25.0, 35.0, 45.0, 55.0]:
        for feed in [20.0, 30.0, 40.0]:
            vals = {
                "feeding_hours": feed, "retention_hours": ret,
                "setup_sg": 1.085, "final_sg": 1.085 - (alc / 200.0),
                "sg_diff": alc / 200.0,
                "setup_alc": 0.0, "final_alc": alc,
                "setup_ph": 4.5, "final_ph": 4.4
            }
            features = [vals.get(name, 0.0) for name in rf_data["feature_names"]]
            class_probs = [0.0] * 3
            for est in rf_data["estimators"]:
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
                        class_probs[i] += (c / tot) / len(rf_data["estimators"])
            best_idx = max(range(3), key=lambda i: class_probs[i])
            lbl = ['low_alcohol', 'normal', 'golden'][best_idx]
            if lbl != 'golden':
                print(f"Alc={alc:4.1f}% | RetH={ret:4.1f} | FeedH={feed:4.1f} -> Pred = {lbl.upper()} (P_normal={class_probs[1]:.2f}, P_low={class_probs[0]:.2f}, P_gold={class_probs[2]:.2f})")
