## Running the Server

1. Install all dependencies (`/app/requirements.txt`)
2. In the app directory run

`conda activate [your pytorch name]`

`uvicorn api:app --reload`

or 

`uvicorn api:app --host 192.168.86.24 --port 8000`


# Additional Notes

Processing devices speed from fast to slow:
`cuda` - Nvidia GPU video cards
`mps` - Other GPU video cards
`cpu` - CPU video cards
