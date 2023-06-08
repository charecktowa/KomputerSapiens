from torch.utils.data import Dataset
from PIL import Image

import file_utils


class BreastHistology(Dataset):
    def __init__(self, root_dir: str, transform=None) -> None:
        self.paths = file_utils.get_image_path(root_dir)

        self.transform = transform

        self.classes, self.class_to_idx = file_utils.find_classes(root_dir)

    def load_image(self, index: int) -> Image.Image:
        image_path = self.paths[index]
        return Image.open(image_path)

    def __len__(self) -> int:
        return len(self.paths)

    def __getitem__(self, index: int) -> tuple[Image.Image, int]:
        img = self.load_image(index)
        class_name = file_utils.get_image_label(self.paths[index])
        class_idx = self.class_to_idx[class_name]

        if self.transform:
            return self.transform(img), class_idx
        else:
            return img, class_idx
