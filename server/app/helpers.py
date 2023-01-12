import os
import uuid
import huggingface_hub
import cv2
import base64
import torch
import io
import warnings
import numpy as np
import onnxruntime as rt

from pydantic import BaseModel
from PIL import Image
from io import BytesIO
import stability_sdk.interfaces.gooseai.generation.generation_pb2 as generation


def get_device_processing_unit():
    if torch.cuda.is_available():
        return "cuda"
    elif torch.backends.mps.is_available():
        return "mps"
    else:
        return "cpu"


# generate image directory and files
def generate_image_directory():
    path = "images/" + uuid.uuid4().hex

    if not os.path.exists(path):
        os.makedirs(path)

    return path

def generate_input_image_path(folder_name: str):
    return folder_name + "/input.jpg"

def generate_mask_image_path(folder_name: str):
    return folder_name + "/mask.jpg"

def generate_output_image_path(folder_name: str):
    return folder_name + "/" + uuid.uuid4().hex + ".jpg"


# generate mask using numpy library
mask_providers = ['CUDAExecutionProvider', 'CPUExecutionProvider']
mask_model_path = huggingface_hub.hf_hub_download("skytnt/anime-seg", "isnetis.onnx")
mask_rmbg_model = rt.InferenceSession(mask_model_path, providers=mask_providers)

def get_mask(img, s=1024):
    img = (img / 255).astype(np.float32)
    h, w = h0, w0 = img.shape[:-1]
    h, w = (s, int(s * w / h)) if h > w else (int(s * h / w), s)
    ph, pw = s - h, s - w

    img_input = np.zeros([s, s, 3], dtype=np.float32)
    img_input[ph // 2:ph // 2 + h, pw // 2:pw // 2 + w] = cv2.resize(img, (w, h))

    img_input = np.transpose(img_input, (2, 0, 1))
    img_input = img_input[np.newaxis, :]

    mask = mask_rmbg_model.run(None, {'img': img_input})[0][0]
    mask = np.transpose(mask, (1, 2, 0))

    mask = mask[ph // 2:ph // 2 + h, pw // 2:pw // 2 + w]
    mask = cv2.resize(mask, (w0, h0))[:, :, np.newaxis]

    return mask

def rmbg_fn(img, reverse: bool):
    mask = get_mask(img)
    img = (mask * img + 255 * (1 - mask)).astype(np.uint8)

    mask = (mask * 255).astype(np.uint8)
    img = np.concatenate([img, mask], axis=2, dtype=np.uint8)

    mask = mask.repeat(3, axis=2)

    if reverse:
        mask = cv2.bitwise_not(mask)

    return mask


# input, mask and output images processor
def prepare_input_image(image_str: str, image_path: str, image_width: int, image_height: int):
    input_image = base64.b64decode(image_str)
    
    with open(image_path, "wb") as f:
        f.write(input_image)

    input_image = Image.open(image_path)
    input_image = input_image.resize((image_width, image_height))
    input_image.save(image_path)

    return input_image

def prepare_mask_image(image_path: str, folder_name: str, reverse_mask: bool):
    input_image = cv2.imread(image_path)
    mask_image_buffer = rmbg_fn(input_image, reverse=reverse_mask)
    mask_image = Image.fromarray(mask_image_buffer, "RGB")

    mask_image_path = generate_mask_image_path(folder_name=folder_name)
    mask_image.save(mask_image_path)

    return mask_image

def generate_runwayml_images_result_from(output: any, folder_name: str):
    output_images = []

    for i, output_image in enumerate(output["images"]):
        if (output["nsfw_content_detected"][i]):
            continue
        else:
            output_images.append(output_image)

            output_image_path = generate_output_image_path(folder_name=folder_name)
            output_image.save(output_image_path)

    images_result = []

    for image in output_images:
        buffer = BytesIO()
        image.save(buffer, format="JPEG")

        images_result.append(base64.b64encode(buffer.getvalue()))

    if not images_result:
        return {
            "status" : 424,
            "message" : "Output Images List is empty. Please try again"
        }

    return {
        "status" : 200,
        "images" : images_result
    }


def generate_stability_images_result_from(output: any, folder_name: str):
    output_images = []

    for resp in output:
        for artifact in resp.artifacts:
            if artifact.finish_reason == generation.FILTER:
                warnings.warn(
                    "Your request activated the API's safety filters and could not be processed."
                    "Please modify the prompt and try again."
                )

                continue

            if artifact.type == generation.ARTIFACT_IMAGE:
                output_image = Image.open(io.BytesIO(artifact.binary))
                output_images.append(output_image)

                output_image_path = generate_output_image_path(folder_name=folder_name)
                output_image.save(output_image_path)

    images_result = []

    for image in output_images:
        buffer = BytesIO()
        image.save(buffer, format="JPEG")

        images_result.append(base64.b64encode(buffer.getvalue()))

    if not images_result:
        return {
            "status" : 424,
            "message" : "Output Images List is empty. Please try again"
        }

    return {
        "status" : 200,
        "images" : images_result
    }


def generate_depth_images_result_from(output: any, folder_name: str):
    output_images = []
    
    for output_image in output.images:
        output_images.append(output_image)

        output_image_path = generate_output_image_path(folder_name=folder_name)
        output_image.save(output_image_path)

    images_result = []

    for image in output_images:
        buffer = BytesIO()
        image.save(buffer, format="JPEG")

        images_result.append(base64.b64encode(buffer.getvalue()))

    if not images_result:
        return {
            "status" : 424,
            "message" : "Output Images List is empty. Please try again"
        }

    return {
        "status" : 200,
        "images" : images_result
    }


class TextToImageRequest(BaseModel):
    prompt: str = ""
    negative_prompt: str = ""
    image_width: int = 512
    image_height: int = 512
    strength: float = 0.9
    guidance_scale: float = 8.0
    samples_count: int = 1
    steps_count: int = 50
    seed: int = 0

class ImageToImageRequest(TextToImageRequest):
    image: str = ""