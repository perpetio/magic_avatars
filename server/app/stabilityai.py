import os
import stability_sdk.interfaces.gooseai.generation.generation_pb2 as generation
import helpers as support

from helpers import TextToImageRequest, ImageToImageRequest
from dotenv import load_dotenv, find_dotenv
from fastapi import FastAPI
from stability_sdk import client


# load environment variables and setup processing device
load_dotenv(find_dotenv())

auth_token = os.environ.get("API_TOKEN")
print("Auth token: ", auth_token)

os.environ['STABILITY_HOST'] = 'grpc.stability.ai:443'
os.environ['STABILITY_KEY'] = auth_token

stability_api = client.StabilityInference(
    key=os.environ['STABILITY_KEY'],
    verbose=True,
    engine="stable-diffusion-v1-5"
)


# start API
app = FastAPI()

@app.get("/")
async def root():
    return {"message" : "App Server is Running"}


@app.post("/v2/text_to_image")
async def text_to_image(request: TextToImageRequest):
    folder_name = support.generate_image_directory()
    
    output = stability_api.generate(
        prompt=request.prompt,
        seed=request.seed,
        steps=request.steps_count,
        cfg_scale=request.guidance_scale,
        width=request.image_width, 
        height=request.image_height, 
        sampler=generation.SAMPLER_K_DPMPP_2M
    )

    return support.generate_stability_images_result_from(
        output=output,
        folder_name=folder_name
    )


@app.post("/v2/image_to_image_inpainting")
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
        reverse_mask=False
    )

    output = stability_api.generate(
        prompt=request.prompt,
        init_image=input_image,
        mask_image=mask_image,
        start_schedule=request.strength,
        seed=request.seed,
        steps=request.steps_count,
        cfg_scale=request.guidance_scale,
        width=request.image_width,
        height=request.image_height,
        sampler=generation.SAMPLER_K_DPMPP_2M
    )

    return support.generate_stability_images_result_from(
        output=output,
        folder_name=folder_name
    )
    

@app.post("/v2/image_to_image")
async def image_to_image(request: ImageToImageRequest):
    folder_name = support.generate_image_directory()
    input_image_path = support.generate_input_image_path(folder_name=folder_name)
    input_image = support.prepare_input_image(
        image_str=request.image, 
        image_path=input_image_path,
        image_width=request.image_width,
        image_height=request.image_height
    )

    output = stability_api.generate(
        prompt=request.prompt,
        init_image=input_image,
        start_schedule=request.strength,
        seed=request.seed,
        steps=request.steps_count,
        cfg_scale=request.guidance_scale,
        width=request.image_width, 
        height=request.image_height, 
        sampler=generation.SAMPLER_K_DPMPP_2M
    )

    return support.generate_stability_images_result_from(
        output=output,
        folder_name=folder_name
    )
