import os
import torch
import helpers as support

from helpers import TextToImageRequest, ImageToImageRequest
from dotenv import load_dotenv, find_dotenv
from diffusers import StableDiffusionImg2ImgPipeline, DiffusionPipeline, StableDiffusionPipeline, StableDiffusionDepth2ImgPipeline
from fastapi import FastAPI


# load environment variables and setup processing device
load_dotenv(find_dotenv())

auth_token = os.environ.get("API_TOKEN")
print("Auth token: ", auth_token)

torch.backends.cudnn.benchmark = True
torch_device = support.get_device_processing_unit()
print("Torch Device: ", torch_device)


# predefine diffusion pipeline using pretrained model
text_to_image_pipe = StableDiffusionPipeline.from_pretrained(
    pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5",
    revision="fp16",
    torch_dtype=torch.float16,
    use_auth_token=auth_token
)

image_to_image_pipe = StableDiffusionImg2ImgPipeline.from_pretrained(
    pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5",
    use_auth_token=auth_token
)

image_to_image_inpainting_pipe = DiffusionPipeline.from_pretrained(
    pretrained_model_name_or_path="runwayml/stable-diffusion-inpainting",
    revision="fp16",
    torch_dtype=torch.float16,
    use_auth_token=auth_token
)

depth_to_image_pipe = StableDiffusionDepth2ImgPipeline.from_pretrained(
   pretrained_model_name_or_path="stabilityai/stable-diffusion-2-depth",
   use_auth_token=auth_token
)

text_to_image_pipe.enable_attention_slicing()
image_to_image_pipe.enable_attention_slicing(1)
image_to_image_inpainting_pipe.enable_attention_slicing()
depth_to_image_pipe.enable_attention_slicing()


text_to_image_pipe = text_to_image_pipe.to(torch_device)
image_to_image_pipe = image_to_image_pipe.to(torch_device)
image_to_image_inpainting_pipe = image_to_image_inpainting_pipe.to(torch_device)
depth_to_image_pipe = depth_to_image_pipe.to(torch_device)


# start API
app = FastAPI()

@app.get("/")
async def root():
    return {"message" : "App Server is Running"}


@app.post("/v1/text_to_image")
async def text_to_image(request: TextToImageRequest):
    folder_name = support.generate_image_directory()
    
    generator = torch.Generator(
        device="cpu"
    ).manual_seed(request.seed)

    output = text_to_image_pipe(
        prompt=request.prompt,
        # strength=request.strength,
        guidance_scale=request.guidance_scale,
        num_inference_steps=request.steps_count,
        generator=generator
    )

    return support.generate_runwayml_images_result_from(
        output=output,
        folder_name=folder_name
    )


@app.post("/v1/image_to_image_inpainting")
async def image_to_image_inpainting(request: ImageToImageRequest):
    folder_name = support.generate_image_directory()
    input_image_path = support.generate_input_image_path(folder_name=folder_name)
    input_image = support.prepare_input_image(
        image_str=request.image, 
        image_path=input_image_path,
        image_width=request.image_width,
        image_height=request.image_height
    )

    mask_image = support.prepare_mask_image(
        image_path=input_image_path,
        folder_name=folder_name,
        reverse_mask=True
    )

    generator = torch.Generator(
        device="cpu"
    ).manual_seed(request.seed)

    output = image_to_image_inpainting_pipe(
        prompt=request.prompt,
        image=input_image,
        mask_image=mask_image,
        # strength=request.strength,
        guidance_scale=request.guidance_scale,
        num_inference_steps=request.steps_count,
        generator=generator
    )

    return support.generate_runwayml_images_result_from(
        output=output,
        folder_name=folder_name
    )
    

@app.post("/v1/image_to_image")
async def image_to_image(request: ImageToImageRequest):
    folder_name = support.generate_image_directory()
    input_image_path = support.generate_input_image_path(folder_name=folder_name)
    input_image = support.prepare_input_image(
        image_str=request.image, 
        image_path=input_image_path,
        image_width=request.image_width,
        image_height=request.image_height
    )

    generator = torch.Generator(
        device="cpu"
    ).manual_seed(request.seed)

    output = image_to_image_pipe(
        prompt=request.prompt,
        negative_prompt=request.negative_prompt,
        image=input_image,
        strength=request.strength,
        guidance_scale=request.guidance_scale,
        num_inference_steps=request.steps_count,
        generator=generator
    )

    return support.generate_runwayml_images_result_from(
        output=output,
        folder_name=folder_name
    )


@app.post("/v1/depth_to_image")
async def depth_to_image(request: ImageToImageRequest):
    folder_name = support.generate_image_directory()
    input_image_path = support.generate_input_image_path(folder_name=folder_name)
    input_image = support.prepare_input_image(
        image_str=request.image, 
        image_path=input_image_path,
        image_width=request.image_width,
        image_height=request.image_height
    )

    output = depth_to_image_pipe(
        prompt=request.prompt, 
        image=input_image,
        negative_prompt=request.negative_prompt,
        strength=request.strength,
        guidance_scale=request.guidance_scale,
        num_inference_steps=request.steps_count
    )

    return support.generate_depth_images_result_from(
        output=output,
        folder_name=folder_name
    )
