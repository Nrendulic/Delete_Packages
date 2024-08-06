Jamf Pro Package Deletion Script

This bash script is designed to delete one or more packages from a Jamf Pro server using the Jamf Pro API. It supports the recent changes introduced in Jamf Pro version 11.5 and above.

Features

Prompts for Jamf Pro server URL, package IDs, username, and password.
Manages authentication via bearer tokens.
Deletes specified packages and provides feedback on the success or failure of each operation.
Invalidates the token after the operation is complete.
Requirements

Bash shell
curl command-line tool
Usage

Run the Script: Execute the script in a terminal.
```
./delete_jamf_packages.sh
```
Provide Details:

The script will prompt for the following:
- Jamf Pro URL: The URL of your Jamf Pro server (ensure to include http:// or https://).
- Package IDs: A comma-separated list of package IDs you wish to delete.
- Username: Your Jamf Pro username.
- Password: Your Jamf Pro password (input will be hidden).

Execution:
The script will authenticate and delete the specified packages, providing feedback for each package deletion.
It will also handle the token lifecycle, ensuring secure access and invalidation post-operation.

Example:
```
Enter the Jamf Pro URL (e.g., https://your.jamf.server:8443): https://your.jamf.server:8443
Enter the Package IDs (comma-separated): 1,2,3
Enter your Jamf Pro username: admin
Enter your Jamf Pro password: 
Token valid until the following epoch time: 1651622400
Package ID 1 deleted successfully.
Package ID 2 deleted successfully.
Package ID 3 deleted successfully.
Token successfully invalidated
```

Important Notes

The Jamf Pro URL must include http:// or https://.
Ensure your Jamf Pro account has the necessary permissions to delete packages.

The script is updated to accommodate changes in Jamf Pro 11.5 and later versions.
License

This project is licensed under the MIT License. See the LICENSE file for details.
