# FastAPI BitNet App Service Sidecar

A FastAPI template with [BitNet](https://huggingface.co/microsoft/bitnet-b1.58-2B-4T-gguf) (Microsoft's lightweight 1-bit transformer model) as a sidecar container on Azure App Service.

## Prerequisites

- [Azure Developer CLI (AZD)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure subscription](https://azure.microsoft.com/free/)
- [Docker](https://www.docker.com/products/docker-desktop/)

## Usage

1. Install AZD and run the following command to initialize the project.

    ```bash
    azd init
    ```

1. Login to your Azure account.

    ```bash
    azd auth login
    ```

1. Run the following command to build a deployable copy of your application, provision the template's infrastructure to Azure and also deploy the applciation code to those newly provisioned resources.

    ```bash
    azd up
    ```

This command will prompt you for the following information:

- `Azure Location`: The Azure location where your resources will be deployed.
- `Azure Subscription`: The Azure Subscription where your resources will be deployed.

> NOTE: This may take a while to complete as it executes three commands: `azd package` (builds a deployable copy of your application), `azd provision` (provisions Azure resources), and `azd deploy` (deploys application code). You will see a progress indicator as it packages, provisions and deploys your application.


## Notes

This uses the P1V3 SKU for app service.

See the [pricing calculator](https://azure.microsoft.com/pricing/calculator/) for details.
