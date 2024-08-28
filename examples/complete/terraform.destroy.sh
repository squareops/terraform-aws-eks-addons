#!/bin/bash
COMMAND="terraform destroy -auto-approve" # terraform destroy command
MAX_RETRIES=3                             # Number of Retry count
RETRY_DELAY=180                           # Default retry interval is 3 Mins

run_with_retries() {                      # Bash retries Function
    local attempt=1
    local initial_run=1

    while [[ $attempt -le $MAX_RETRIES ]]; do
        if [[ $initial_run -eq 1 ]]; then
            echo "Initial attempt to destroy command..."
            $COMMAND                                      # Destroy the terraform state
            EXIT_CODE=$?                                  # Exit Code stored (logic)

            if [[ $EXIT_CODE -eq 0 ]]; then               # logic (EXIT CODE = '0' means sucess)
                echo "Initial command succeeded."
                return 0
            else
                echo "Initial command failed with exit code $EXIT_CODE."
                initial_run=0                              # Run only if intitial run fails
                attempt=2                                  # logic
            fi
        else
            echo "Retry attempt $attempt of $MAX_RETRIES..."

            $COMMAND                                       # Retry terraform destroy
            EXIT_CODE=$?                                   # Update Exit Code Status

            if [[ $EXIT_CODE -eq 0 ]]; then                # Recursive retry till destroy succeed
                echo "Command succeeded on attempt $attempt."
                return 0
            else
                echo "Command failed with exit code $EXIT_CODE."
                if [[ $attempt -lt $MAX_RETRIES ]]; then
                    echo "Retrying in $RETRY_DELAY seconds..."
                    sleep $RETRY_DELAY
                else
                    echo "Maximum retries reached. Exiting."
                    return 1
                fi
            fi
        fi

        attempt=$((attempt + 1))
    done
}

run_with_retries                                           # Call the bash function
