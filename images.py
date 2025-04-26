import os
import re
import shutil

# Paths (using raw strings to handle Windows backslashes correctly)
posts_dir = r"C:\Users\TK-LPT-1025\Documents\nbin\blog\sshmeblog\content\archive"
attachments_dir = r"G:\My Drive\blog"
static_images_dir = r"C:\Users\TK-LPT-1025\Documents\nbin\blog\sshmeblog\static\images"

# Step 1: Process each markdown file in the posts directory
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)

        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()

        # Step 2: Find all image links (png, jpg, gif)
        images = re.findall(r'\[\[([^]]*\.(png|jpg|gif))\]\]', content)

        # Step 3: Replace image links and ensure URLs are correctly formatted
        for image_tuple in images:
            image = image_tuple[0]
            markdown_image = f"[Image Description](/images/{image.replace(' ', '%20')})"
            content = content.replace(f"[[{image}]]", markdown_image)

            # Step 4: Copy the image to the Hugo static/images directory if it exists
            image_source = os.path.join(attachments_dir, image)
            if os.path.exists(image_source):
                shutil.copy(image_source, static_images_dir)

        # Step 5: Write the updated content back to the markdown file
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(content)

print("Markdown files processed and images (png, jpg, gif) copied successfully.")