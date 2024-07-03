#!/bin/bash

# Declare the user and groups arrays
users=()
groups=()

# Define the paths for log and password files
log_file="/var/log/user_management.log"
password_file="/var/secure/user_passwords.txt"

# Function to read the input file
function read_input_file() {
    local file="$1"
    # Read the input file
    while IFS= read -r line; do
        user=$(echo "$line" | cut -d';' -f1 | tr -d '[:space:]')
        group=$(echo "$line" | cut -d';' -f2 | tr -d '[:space:]')
        # Add the user to the users array
        users+=("$user")
        # Add the group to the groups array
        groups+=("$group")
    done < "$file"
}

# Check if exactly one argument is passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Read the input file
input_file="$1"
echo "Reading your input file: $input_file"
read_input_file "$input_file"

# Check if the log and password files exist, and create them if not
if [ ! -f "$log_file" ]; then
    mkdir -p /var/log
    touch "$log_file"
    chmod 640 "$log_file"
fi

if [ ! -f "$password_file" ]; then
    mkdir -p /var/secure
    touch "$password_file"
    chmod 600 "$password_file"
fi

# Iterate over the users array
for (( i = 0; i < ${#users[@]}; i++ )); do
    user="${users[$i]}"
    user_groups="${groups[$i]}"
    
    if id "$user" &>/dev/null; then
        echo "User $user already exists, Skipped" | tee -a "$log_file"
    else
        # Create user
        useradd -m -s /bin/bash "$user"
        if [[ $? -ne 0 ]]; then
            echo "Create User $user failed" | tee -a "$log_file"
            exit 1
        fi
        echo "User $user created successfully" | tee -a "$log_file"

        # Set password
        password=$(openssl rand -base64 50 | tr -dc 'A-Za-z0-9!?%=' | head -c 10)
        echo "$user:$password" | chpasswd
        if [[ $? -ne 0 ]]; then
            echo "Set password for $user failed" | tee -a "$log_file"
            exit 1
        fi
        echo "Password for $user set successfully" | tee -a "$log_file"
        echo "$user,$password" >> "$password_file"

        # Add user to personal group
        usermod -aG "$user" "$user"
        if [[ $? -ne 0 ]]; then
            echo "Add user $user to personal group failed" | tee -a "$log_file"
            exit 1
        fi
        echo "User $user added to personal group successfully" | tee -a "$log_file"

        # Add user to other groups
        IFS=',' read -r -a group_array <<< "$user_groups"
        for group in "${group_array[@]}"; do
            if grep -q "^$group:" /etc/group; then
                echo "Group $group already exists" | tee -a "$log_file"
            else
                groupadd "$group"
                if [[ $? -ne 0 ]]; then
                    echo "Create group $group failed" | tee -a "$log_file"
                    exit 1
                fi
                echo "Group $group created successfully" | tee -a "$log_file"
            fi
            usermod -aG "$group" "$user"
            if [[ $? -ne 0 ]]; then
                echo "Add user $user to group $group failed" | tee -a "$log_file"
                exit 1
            fi
            echo "User $user added to group $group successfully" | tee -a "$log_file"
        done
    fi
done

exit 0
