import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk, ImageDraw
import os

class WallpaperCreator:
    def __init__(self, root):
        self.root = root
        self.root.title("Wallpaper Creator")

        # Default values
        self.bg_color = "#FFFFFF"
        self.bg_width = 1920
        self.bg_height = 1080

        self.init_ui()

        self.selected_image = None
        self.image_objects = []  # Store image objects for dragging
        self.is_cropping = False

    def init_ui(self):
        # Set up control panel
        control_panel = tk.Frame(self.root)
        control_panel.pack(side=tk.TOP, fill=tk.X)

        # Set background resolution
        tk.Label(control_panel, text="Resolution:").pack(side=tk.LEFT)
        self.width_entry = tk.Entry(control_panel, width=5)
        self.width_entry.insert(0, "1920")
        self.width_entry.pack(side=tk.LEFT)

        tk.Label(control_panel, text="x").pack(side=tk.LEFT)
        self.height_entry = tk.Entry(control_panel, width=5)
        self.height_entry.insert(0, "1080")
        self.height_entry.pack(side=tk.LEFT)

        # Set background color
        tk.Label(control_panel, text="Background Color:").pack(side=tk.LEFT)
        self.bg_color_entry = tk.Entry(control_panel, width=10)
        self.bg_color_entry.insert(0, "#FFFFFF")
        self.bg_color_entry.pack(side=tk.LEFT)

        # Set Background Button
        set_bg_button = tk.Button(control_panel, text="Set Background", command=self.set_background)
        set_bg_button.pack(side=tk.LEFT)

        # Add image button
        add_image_button = tk.Button(control_panel, text="Add Image", command=self.add_image)
        add_image_button.pack(side=tk.LEFT)

        # Center image button
        center_button = tk.Button(control_panel, text="Center Image", command=self.center_image)
        center_button.pack(side=tk.LEFT)

        # Crop button
        crop_button = tk.Button(control_panel, text="Circle Crop", command=self.start_crop)
        crop_button.pack(side=tk.LEFT)

        # Save wallpaper button
        save_button = tk.Button(control_panel, text="Export", command=self.save_wallpaper)
        save_button.pack(side=tk.LEFT)

        # Canvas to hold wallpaper
        self.canvas = tk.Canvas(self.root, width=self.bg_width, height=self.bg_height)
        self.canvas.pack(fill=tk.BOTH, expand=True)

        # Resize image controls
        self.resize_width_entry = tk.Entry(control_panel, width=5)
        self.resize_width_entry.pack(side=tk.RIGHT)
        self.resize_height_entry = tk.Entry(control_panel, width=5)
        self.resize_height_entry.pack(side=tk.RIGHT)

        resize_button = tk.Button(control_panel, text="Resize", command=self.resize_image)
        resize_button.pack(side=tk.RIGHT)

        # Circle crop dimensions
        self.crop_width_entry = tk.Entry(control_panel, width=5)
        self.crop_width_entry.insert(0, "100")
        self.crop_width_entry.pack(side=tk.RIGHT)

        tk.Label(control_panel, text="Crop Width:").pack(side=tk.RIGHT)

        self.crop_height_entry = tk.Entry(control_panel, width=5)
        self.crop_height_entry.insert(0, "100")
        self.crop_height_entry.pack(side=tk.RIGHT)

        tk.Label(control_panel, text="Crop Height:").pack(side=tk.RIGHT)

    def set_background(self):
        # Set background color and size
        self.bg_width = int(self.width_entry.get())
        self.bg_height = int(self.height_entry.get())
        self.bg_color = self.bg_color_entry.get()

        # Update canvas size and background color
        self.canvas.config(width=self.bg_width, height=self.bg_height)
        self.canvas.create_rectangle(0, 0, self.bg_width, self.bg_height, fill=self.bg_color)

    def add_image(self):
        # Open file dialog to select an image
        image_path = filedialog.askopenfilename(filetypes=[("Image files", "*.png;*.jpg;*.jpeg")])
        if image_path:
            # Load image using PIL
            img = Image.open(image_path)
            img.thumbnail((self.bg_width, self.bg_height))  # Resize to fit canvas

            # Convert image for tkinter
            img_tk = ImageTk.PhotoImage(img)

            # Add image to canvas
            img_obj = self.canvas.create_image(0, 0, anchor=tk.NW, image=img_tk)
            self.image_objects.append((img, img_obj, img_tk))

            # Store reference
            self.canvas.tag_bind(img_obj, "<Button-1>", self.select_image)
            self.selected_image = img_obj
            self.canvas.bind("<B1-Motion>", self.drag_image)

            # Update image display for selection
            self.update_image_size_entries()

    def select_image(self, event):
        # Get clicked image object
        self.selected_image = event.widget.find_closest(event.x, event.y)[0]
        self.update_image_size_entries()

    def update_image_size_entries(self):
        # Update width and height of selected image in the UI
        if self.selected_image:
            for img, img_obj, img_tk in self.image_objects:
                if img_obj == self.selected_image:
                    self.resize_width_entry.delete(0, tk.END)
                    self.resize_height_entry.delete(0, tk.END)
                    self.resize_width_entry.insert(0, img.width)
                    self.resize_height_entry.insert(0, img.height)

    def drag_image(self, event):
        # Dragging the selected image
        if self.selected_image:
            self.canvas.coords(self.selected_image, event.x, event.y)

    def center_image(self):
        # Center selected image on the canvas
        if self.selected_image:
            for img, img_obj, img_tk in self.image_objects:
                if img_obj == self.selected_image:
                    img_w, img_h = img.size
                    x = (self.bg_width - img_w) // 2
                    y = (self.bg_height - img_h) // 2
                    self.canvas.coords(self.selected_image, x, y)

    def resize_image(self):
        # Resize the selected image based on entry values
        if self.selected_image:
            for i, (img, img_obj, img_tk) in enumerate(self.image_objects):
                if img_obj == self.selected_image:
                    new_width = int(self.resize_width_entry.get())
                    new_height = int(self.resize_height_entry.get())
                    resized_img = img.resize((new_width, new_height))

                    # Convert resized image to tkinter format and update canvas
                    img_tk_resized = ImageTk.PhotoImage(resized_img)
                    self.canvas.itemconfig(img_obj, image=img_tk_resized)
                    self.image_objects[i] = (resized_img, img_obj, img_tk_resized)

    def start_crop(self):
        # Toggle crop mode
        self.is_cropping = not self.is_cropping
        if self.is_cropping:
            self.crop_image()
        else:
            self.update_canvas()

    def crop_image(self):
        # Crop the selected image in circular shape
        if self.selected_image:
            for img, img_obj, img_tk in self.image_objects:
                if img_obj == self.selected_image:
                    crop_width = int(self.crop_width_entry.get())
                    crop_height = int(self.crop_height_entry.get())
                    center_x = img.width // 2
                    center_y = img.height // 2

                    # Create circular mask
                    mask = Image.new("L", (crop_width, crop_height), 0)
                    draw = ImageDraw.Draw(mask)
                    draw.ellipse((0, 0, crop_width, crop_height), fill=255)

                    # Create a new black background image
                    cropped_img = Image.new("RGBA", (crop_width, crop_height), (0, 0, 0, 0))

                    # Crop the selected image
                    img_crop = img.crop((center_x - crop_width // 2, center_y - crop_height // 2,
                                          center_x + crop_width // 2, center_y + crop_height // 2))

                    # Paste the cropped image onto the black background with the circular mask
                    cropped_img.paste(img_crop, (0, 0), mask)

                    # Convert cropped image for tkinter
                    cropped_img_tk = ImageTk.PhotoImage(cropped_img)

                    # Update the canvas with the cropped image preview
                    self.canvas.itemconfig(img_obj, image=cropped_img_tk)
                    self.image_objects[self.image_objects.index((img, img_obj, img_tk))] = (cropped_img, img_obj, cropped_img_tk)

                    # Display the circular cropped image
                    self.canvas.create_image(0, 0, anchor=tk.NW, image=cropped_img_tk)

    def update_canvas(self):
        # Refresh the canvas to show the original image
        if self.selected_image:
            for img, img_obj, img_tk in self.image_objects:
                if img_obj == self.selected_image:
                    self.canvas.itemconfig(img_obj, image=img_tk)

    def save_wallpaper(self):
        # Export the canvas content as an image
        export_path = filedialog.askdirectory()
        if export_path:
            wallpaper = Image.new("RGB", (self.bg_width, self.bg_height), self.bg_color)

            # Paste images onto the wallpaper
            for img, img_obj, _ in self.image_objects:
                x, y = self.canvas.coords(img_obj)
                wallpaper.paste(img, (int(x), int(y)), img.convert("RGBA"))

            # Save as PNG for best quality
            save_file_path = os.path.join(export_path, "wallpaper.png")
            wallpaper.save(save_file_path, "PNG")
            print(f"Wallpaper saved at: {save_file_path}")

if __name__ == "__main__":
    root = tk.Tk()
    app = WallpaperCreator(root)
    root.mainloop()
