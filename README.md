# Startup Bash

Startup Bash is a repository containing a `fresh.sh` script designed to streamline the initial setup and configuration of a new Linux environment.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Script Overview](#script-overview)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

Follow these instructions to set up and run the `fresh.sh` script on your local machine.

### Prerequisites

Before you begin, ensure you have met the following requirements:

- You have a Debian or Ubuntu based operating system.
- You have `bash` installed on your machine.

### Installation

1. Clone the repository to your local machine or download the repository:
   ```bash
   git clone https://github.com/neomagic100/startup-bash.git
   ```


2. Navigate to the cloned directory:
   ```bash
   cd startup-bash
   ```
3. Copy the sample-user.txt file and name it user.txt. Edit it with your name and e-mail:
```bash
   cp sample-user.txt user.txt
```
```bash
   nano user.txt

   Name=<Your Name>
   Email=<Your E-mail>
```

### Usage

The main script in this repository is `fresh.sh`. This script is designed to be run directly without any additional function calls.

To execute the script:

1. Make the script executable:
   ```bash
   chmod +x fresh.sh
   ```

2. Run the script:
   ```bash
   ./fresh.sh
   ```

## Script Overview

The `fresh.sh` script performs various tasks to set up and configure your Linux environment. It includes steps to prompt the user for input using `whiptail`, among other setup tasks.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
