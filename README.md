# Magic Avatars

[![N|Solid](https://github.com/perpetio/magic_avatars/blob/main/cover.png)](https://github.com/perpetio/magic_avatars)

In this repository, we look at several approaches to creating avatars, changing backgrounds, and deep image processing for more detailed output. It is also worth noting that we use both ready-made solutions, namely the *Stability AI SDK* (paid solution), and direct interaction with predefined models (free solution).

## Features

- Text-to-Image
- Image-to-Image
- Replace-Background
- Depth-to-Image

## Tech Stack

- iOS app - SwiftUI
- Server - Python

## iOS App

Magic Avatars app requires latest Xcode version to run.

**Initial state:**

![]((https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-1.png))
<img src="https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-1.png"  width="380" height="844">


**Magic Avatar:**

![]((https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-2.png))
<img src="https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-2.png"  width="380" height="844">


**Replace Background:**

![]((https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-3.png))
<img src="https://github.com/perpetio/magic_avatars/blob/main/iOS-app-screenshot-3.png"  width="380" height="844">


## Server Installation

Install all dependencies (/app/requirements.txt)
In the app directory run

```sh
conda activate {conda env name}
uvicorn api:app --host {your ip-address} --port {port}
```

- port - 8000 or smth else

## Additional Notes

Processing devices speed from fast to slow: 
- cuda - Nvidia GPU video cards
- mps - Other GPU video cards
- cpu - CPU video cards

## License

MIT
