#  Linux User Creation Bash Script
## Task
### Your company has employed many new developers. As a SysOps engineer, write a bash script called create_users.sh that reads a text file containing the employee’s usernames and group names, where each line is formatted as user;groups.
### The script should create users and groups as specified, set up home directories with appropriate permissions and ownership, generate random passwords for the users, and log all actions to /var/log/user_management.log. Additionally, store the generated passwords securely in /var/secure/user_passwords.txt.
### Ensure error handling for scenarios like existing users and provide clear documentation and comments within the script.

## Explaination

The first step I took is to define the input file, then I defined the log and password file. After doing all the defining, I created a function to log messages to the log file. Next step is generate a random password and I used a function for that. Next step is to create and give permissions to the log file and password files.
After that, I added a while loop to read the input file line by line and then next step was creating the user and their personal groups.
After this, I added the users to their groups and then generated a random password for each user. 
At the end of it all, I made sure there's adequate error handling that is, any issues encountered during user and group creaton is logged into the management.log file.