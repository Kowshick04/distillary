import json

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

# Test Golden batch params
golden_batch = {
    "feeding_hours": 28.5, "retention_hours": 20.0,
    "setup_sg": 1.085, "final_sg": 1.030, "sg_diff": 0.055,
    "setup_alc": 0.0, "final_alc": 13.2,
    "setup_ph": 4.5, "final_ph": 4.65
}

# Test Normal batch params (lower final alcohol, longer retention)
normal_batch = {
    "feeding_hours": 36.0, "retention_hours": 42.0,
    "setup_sg": 1.080, "final_sg": 1.050, "sg_diff": 0.030,
    "setup_alc": 0.0, "final_alc": 10.8,
    "setup_ph": 4.5, "final_ph": 4.30
}

# Test Low alcohol / Risk batch
low_alc_batch = {
    "feeding_hours": 40.0, "retention_hours": 50.0,
    "setup_sg": 1.075, "final_sg": 1.060, "sg_diff": 0.015,
    "setup_alc": 0.0, "final_alc": 8.5,
    "setup_ph": 4.2, "final_ph": 4.10
}

lbl1, c1, p1 = predict(golden_batch)
lbl2, c2, p2 = predict(normal_batch)
lbl3, c3, p3 = predict(low_alc_batch)

print(f"Batch 1 (Golden Test):  Pred = {lbl1.upper()} (Confidence: {c1:.1f}%) [Probs: {p1}]")
print(f"Batch 2 (Normal Test):  Pred = {lbl2.upper()} (Confidence: {c2:.1f}%) [Probs: {p2}]")
print(f"Batch 3 (Low Alc Test): Pred = {lbl3.upper()} (Confidence: {c3:.1f}%) [Probs: {p3}]")
