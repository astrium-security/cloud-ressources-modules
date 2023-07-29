# Cloud Resources Modules
Welcome to the Cloud Resources Modules repository. This repository contains a collection of Terraform modules designed to simplify the management of various cloud resources across different providers, namely AWS, Google Cloud Platform (GCP), and Azure (AZR).

The purpose of this repository is to provide ready-to-use Terraform modules for various cloud resources, organized by providers and products. We offer two types of modules: standalone resource modules, like a simple VPC creation, and resource set modules, like a VPC with its associated public and private subnets.

## Repository Structure
This repository is organized into directories, each representing a different cloud provider (AWS, GCP, AZR). Within each provider directory, modules are divided into two main categories:

- **Standalone Resource Modules**: These are modules dedicated to managing a single, isolated resource, like creating a simple VPC.
- **Resource Set Modules**: These modules are used to manage a collection of related resources as a group, such as creating a VPC along with its associated private and public subnets.

Each module comes with its own README file that explains the role of the module, how to configure it, and how to use it.

```
.
├── azr
│   ├── README.md
│   ├── product1
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── standalone_resources
│   │   ├── README.md
│   │   ├── vpc
│   │   │   ├── README.md
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ...
├── aws
│   ├── README.md
│   ├── product1
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── standalone_resources
│   │   ├── README.md
│   │   ├── vpc
│   │   │   ├── README.md
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ...
└── gcp
    ├── README.md
    ├── product1
    │   ├── README.md
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── standalone_resources
        ├── README.md
        ├── vpc
        │   ├── README.md
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── ...
```

## Contributing
Contributions to this repository are welcome. Please make sure to read our Contribution Guidelines and our Code of Conduct before making a pull request.

### Creating a new module with `create_module.sh`

We provide a bash script called `create_module.sh` to help you create a new module in this repository. The script automates the process of creating the necessary directories and files for a new Terraform module.

Here is how to use the script:

1. First, ensure the script is executable. You can do this by running the following command:

    ```bash
    chmod +x create_module.sh
    ```

2. Next, you can create a new module by providing the cloud provider and module name as arguments to the script. For example, if you wanted to create a new AWS module called `my_new_module`, you would run:

    ```bash
    ./create_module.sh aws my_new_module
    ```

3. The script will then ask you if this is a standalone module. If the module is a standalone resource, enter `y`. If the module is a set of resources, enter `n`.

4. The script will create the necessary directories and files for your new module. You can then start working on your module.

Contributions to this repository are welcome. Please make sure to read our Contribution Guidelines and our Code of Conduct before making a pull request.


## License
This project is licensed under the MIT License. See the LICENSE file for details.

