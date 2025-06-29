# CLI Command Generator

This Bash script is a powerful and flexible tool designed to **streamline your command-line workflow by automatically generating modular Bash functions from simple JSON configuration files**. Instead of repeatedly typing long and complex `curl` commands or other CLI instructions, you can define them once in a JSON file. This script then converts these definitions into easy-to-use Bash functions that seamlessly integrate into your shell environment. It's particularly useful for **managing a series of complex API calls, interacting with cloud services, or automating repetitive tasks**, allowing you to execute them using simple, memorable function names, just like built-in command-line tools.

---

## Features

This command generator offers several key features to enhance your CLI experience:

- **Modular Design**: Organize your commands efficiently. Each JSON file defines a "module," and all generated functions associated with that file will be prefixed with the module's name (e.g., `api_ex_login`, `api_ex_get_user_info`). This prevents naming conflicts and keeps your shell environment tidy.
- **Flexible Command Definition**: Easily define sophisticated `curl` commands or any other command-line tool with numerous parameters. The JSON structure allows for clear and concise definition of complex command arguments.
- **Dynamic Environment Variable Integration**: Commands can dynamically incorporate environment variables (e.g., `${API_KEY}`, `${SERVER_IP}`). This feature significantly boosts flexibility, allowing you to manage sensitive information or configurable values outside your command definitions.
- **Function Parameter Support**: Generated Bash functions can accept positional arguments, which are then mapped to user-defined variables within your JSON configuration. This enables you to create versatile commands that take specific inputs (e.g., `api_ex_login "username" "password"`).
- **Dry Run Mode for Safe Testing**: Test your command definitions without actual execution. The dry run mode prints the complete command string to the console, allowing for easy debugging and verification of the generated command before it runs.
- **Automated Documentation Functions**: The script automatically generates helper functions:
  - `_list`: Lists all available commands (functions) for a given module, providing a quick overview.
  - `_about`: Provides detailed information for each command, including a breakdown of its purpose and a list of all required environment variables.

---

## Installation

This tool relies on `jq`, a lightweight and flexible command-line JSON processor, to parse your JSON configuration files.

### 1. Install `jq`

If you don't have `jq` installed, follow the instructions for your operating system:

- **macOS (using Homebrew)**:
  ```bash
  brew install jq
  ```
- **Debian/Ubuntu**:
  ```bash
  sudo apt-get update
  sudo apt-get install jq
  ```
- **CentOS/RHEL**:
  ```bash
  sudo yum install jq
  ```
- **Other Operating Systems**: Refer to the [official jq installation guide](https://jqlang.github.io/jq/download/) for more options.

### 2. Download the `generate_module_commands.sh` Script

Save the `generate_module_commands.sh` script to a location in your system (e.g., `~/bin/` or your project directory).

```bash
# Example if fetching from a URL (replace with your actual script URL if hosted)
# curl -o generate_module_commands.sh YOUR_RAW_SCRIPT_URL_HERE

# After saving the file, make it executable:
chmod +x generate_module_commands.sh
```

---

## Usage Guide

Follow these steps to define, generate, and use your custom CLI commands:

1. Create a JSON Configuration File
   Define your commands within a JSON file. The filename should be your module name followed by a `.json` extension (e.g., `api_ex.json`). This file will contain an array of command definitions.

Example `api_ex.json`:

```json
[
  {
    "name": "login",
    "command": "curl",
    "variable": ["username", "password"],
    "argument": [
      "--insecure",
      "--silent",
      "--max-time",
      "${CURL_TIMEOUT}",
      "--cookie-jar",
      "${MY_COOKIE}",
      "--write-out",
      "\\nResponse code: %{http_code}\\nResponse time: %{time_total}\\n",
      "--request",
      "POST",
      "--header",
      "content-type: application/json",
      "-d",
      "username=${username}",
      "-d",
      "password=${password}",
      "https://${SERVER_IP}/login"
    ]
  },
  {
    "name": "get_user_info",
    "command": "curl",
    "variable": ["user_id"],
    "argument": [
      "--insecure",
      "--silent",
      "--cookie",
      "${MY_COOKIE}",
      "${BASE_URL}/users/${user_id}"
    ]
  }
]
```

2. Generate Bash Functions
   Run the `generate_module_commands.sh` script to create the Bash functions. The first argument to the script must be your module name (which corresponds to your JSON filename without the `.json` extension).

- Generate functions for normal execution: These functions will execute the defined commands directly.

```bash
./generate_module_commands.sh api_ex
```

- Generate functions for Dry Run mode: These functions will only print the command string to the console, allowing you to review it before actual execution. This is highly recommended for debugging.

```bash
./generate_module_commands.sh api_ex dryrun
```

This will create `api_ex_dryrun_functions.sh`.

3. Load and Use the Functions

To make the generated functions available in your current shell session, source the generated script:

```bash
source api_ex_functions.sh # Or api_ex_dryrun_functions.sh for dry run
```

### Discover Your Commands:

- List all commands in the module:

```bash
api_ex_list
```

This will output a neatly formatted list of all functions you've defined in api_ex.json, such as `api_ex_login`, `api_ex_get_user_info`, etc.

- Get detailed information and required variables:

```bash
api_ex_about
```

This provides a comprehensive overview of each command, including a description and a crucial list of environment variables (e.g., `CURL_TIMEOUT`, `MY_COOKIE`, `SERVER_IP`) that must be set in your shell environment before the command can run successfully.

### Set Required Environment Variables:

Before executing your generated commands, ensure all necessary environment variables (as identified by `_about`) are set in your shell.

```bash
# Example: Setting variables based on the api_ex.json requirements
export CURL_TIMEOUT=15
export MY_COOKIE="/tmp/api_ex_cookies.txt"
export SERVER_IP="192.168.1.100" # Replace with your actual server IP or domain
export BASE_URL="https://${SERVER_IP}/api/v1"
```

### Execute Your Custom Commands:

Once environment variables are set, you can call your custom commands just like any other Bash function, passing any defined function-specific parameters.

```bash
# Execute the login function, providing username and password as arguments
api_ex_login "john.doe" "your_secure_password"

# Execute the get_user_info function, providing a user ID
api_ex_get_user_info "12345"
```

---

## JSON Configuration File Format Reference

The JSON configuration file is a JSON array, where each element represents a single command-line function to be generated. Each element is an object and should contain the following key-value pairs:

- `name` (string, **_required_**):

  - This is the core name of the Bash function that will be generated (e.g., "login", "get_user_info"). When combined with the module name, it forms the full function name (e.g., `api_ex_login`).

- `command` (string, optional, default: `"curl"`):

  - Specifies the base command to be executed. While primarily designed for `"curl"`, you can use any command-line utility here, such as `"kubectl"`, `"aws"`, `"git"`, etc.

- variable (array of strings, optional):

  - An array containing the names of parameters that the generated Bash function will accept. These names correspond to the positional arguments passed to the function (e.g., `$1`, `$2`).

  - Example: If [`"username"`, `"password"`] is specified, the generated function will be callable with two arguments: `my_func` `arg1` `arg2`. Within the argument field, you can then reference these as \${username} and \${password}.

- `argument` (array of strings, **_required_**):

  - This is a crucial array containing all individual arguments and options to be passed to the `command`. Each element in this array will be treated as a separate argument for the command.

  - You can embed environment variables (e.g., `${MY_API_KEY}`) or function parameters (e.g., `${username}`) directly within these argument strings.

---

## FAQ & Troubleshooting

- `curl`: option `--max-time`: expected a proper numerical parameter or other curl errors:

  - This usually indicates that an environment variable required by the command (as prompted by the `_about` function) is either not set or its value is invalid (e.g., `CURL_TIMEOUT` is not a number).

  - Solution: Double-check that all required environment variables are exported in your shell with correct and valid values before calling the function.

- Incomplete function list or "about" information:

  - Solution: Ensure `jq` is correctly installed and accessible in your PATH. Also, verify that your JSON configuration file is syntactically correct and matches the expected format.

- Shell syntax errors (e.g., syntax error near unexpected token 'newline') during function execution:

  - This can happen if the generated Bash script has unexpected characters.

  - Solution: Ensure you're using the most up-to-date version of the generate_module_commands.sh script, as previous versions might have had minor generation quirks. Consider re-downloading the script.

---

## Contributing

Contributions are always welcome! If you encounter any bugs, have suggestions for new features, or want to improve existing code, please feel free to:

- Open an Issue to report bugs or suggest enhancements.

- Submit a Pull Request with your proposed changes.
