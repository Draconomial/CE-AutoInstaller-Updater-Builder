# Combat Extended Auto-Installer/Updater/Builder

To run this batch script, ensure you have the following requirements:
Windows Operating System: The batch script is designed to run on Windows.
Batch Script Interpreter: The script requires the Windows Command Prompt (cmd.exe) to execute.
The following is checked for and installed if it is missing:
Git: The script uses Git commands for fetching, pulling, and cloning repositories. Ensure Git is installed and added to your system's PATH environment variable so that the git command can be executed from the command line.
dotnet SDK: The script uses the dotnet command to build the .sln files. Ensure the .NET SDK is installed on your system.

Additionally, ensure you have appropriate permissions to execute scripts and access the required directories.

If any of these components are missing or misconfigured, the script might encounter issues when executing Git or dotnet commands. Install Git and the .NET SDK if you haven't already and ensure they are properly configured in your system's environment variables.

You can check the availability and versions of Git and the .NET SDK by opening a Command Prompt window and typing git --version and dotnet --version. If these commands return their respective versions without errors, the required tools are installed and available for use within the script.
