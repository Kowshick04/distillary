from PIL import Image
import os

source_path = "empty_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png"
res_dir = "android/app/src/main/res"

densities = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

img = Image.open(source_path).convert("RGBA")

# Calculate bounding box of non-transparent pixels
bbox = img.getbbox()
if bbox:
    cropped = img.crop(bbox)
else:
    cropped = img

# Target safe-zone ratio (e.g. logo takes ~75-80% of canvas width/height to avoid squircle clipping)
for folder, size in densities.items():
    folder_path = os.path.join(res_dir, folder)
    os.makedirs(folder_path, exist_ok=True)
    out_file = os.path.join(folder_path, "ic_launcher.png")
    
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    target_inner_size = int(size * 0.82)
    
    # Resize cropped keeping aspect ratio
    w, h = cropped.size
    scale = min(target_inner_size / w, target_inner_size / h)
    new_w, new_h = int(w * scale), int(h * scale)
    resized = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    offset_x = (size - new_w) // 2
    offset_y = (size - new_h) // 2
    canvas.paste(resized, (offset_x, offset_y), resized)
    
    canvas.save(out_file, "PNG", optimize=True)
    print(f"Generated {out_file}: {size}x{size}")

print("All launcher icons generated successfully!")
