# BitNet FastAPI Chat App

A web-based chat application that leverages BitNet b1.58-2B-4T for inference, deployed on Azure App Service with a sidecar container architecture.

## Overview

This application provides a simple web interface to interact with BitNet, a 1-bit large language model designed for efficient inference. The app uses:

- **FastAPI**: High-performance web framework for building APIs
- **BitNet b1.58-2B-4T**: Official 2B parameter 1-bit LLM model
- **Azure App Service**: PaaS hosting with sidecar container support
- **Bicep & Azure Developer CLI (azd)**: Infrastructure as Code and deployment pipeline

## Architecture

The application uses a sidecar container pattern on Azure App Service:

- **Main Container**: Runs the FastAPI application
- **BitNet Sidecar**: Runs the BitNet model inference service
- **Communication**: Main app connects to the sidecar via localhost

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [Python 3.11+](https://www.python.org/downloads/)

## Local Development

To run the application with BitNet inference locally, you'll need to follow the setup instructions from the [BitNet repository](https://github.com/microsoft/BitNet) and make sure it is running on the port your api is working with.

Then you can run this API.

1. clone and run the FastAPI application:

   ```bash
   git clone https://github.com/yourusername/bitnet-fastapi-chat.git
   cd bitnet-fastapi-chat
   
   # Set up virtual environment
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   
   # Install dependencies
   pip install -r requirements.txt
   
   # Run the app
   ENDPOINT=http://localhost:11434/v1 uvicorn app:app --reload
   ```

## Deployment to Azure

1. Log in to Azure:

   ```bash
   az login
   ```

2. Initialize Azure Developer CLI:

   ```bash
   azd init
   ```

3. Deploy the application:

   ```bash
   azd up
   ```

## Application Configuration

Key application settings used by the app:

- `ENDPOINT`: URL for BitNet inference API (http://localhost:11434/v1)
- `MODEL`: Name of BitNet model (bitnet-b1.58-2b-4t-gguf)
- `SIDECAR_PORT`: Port for BitNet sidecar (11434)
- `WEBSITES_ENABLE_APP_SERVICE_STORAGE`: Enables persistent storage (set to 'true')
- `WEBSITE_ENABLE_SIDECAR`: Enables sidecar containers (set to 'true')

## BitNet Model Information

This application uses the BitNet b1.58-2B-4T model, which is a 1-bit large language model with 2.4B parameters. Key characteristics:

- Model size: 1.10 GiB (3.91 Bytes Per Weight)
- Fast CPU inference (optimized with bitnet.cpp)
- Energy-efficient operation (up to 82% reduction compared to full-precision models)
- Suitable for edge and resource-constrained environments

## Performance Considerations

The application is designed to work with:

- Minimum: Basic B3 tier (4 vCPUs, 7GB RAM)
- Recommended: Premium v3 P1v3 tier or higher (2+ vCPUs, 8GB+ RAM)
- Production: Premium v3 P2v3 tier (4 vCPUs, 16GB RAM)

Actual performance will depend on workload:

- Response generation: 5-10 tokens per second on average
- Memory usage: ~1.5GB for model + application overhead
- Concurrent users: P1v3 can handle ~5-10 simultaneous users, P2v3 can handle ~10-20

## License

[MIT License](LICENSE)

## Notes

This uses the P1V3 SKU for app service.

See the [pricing calculator](https://azure.microsoft.com/pricing/calculator/) for details.
