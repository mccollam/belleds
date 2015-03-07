# belleds
Simple utilities for working with the Belleds Q Station and color-changing light bulbs.

Edit environment.conf to reflect your Q Station's IP address and your bulb serial numbers.

You will need to install the jq package (for JSON parsing) to use these scripts.  (In Ubuntu, this is 'sudo apt-get install jq'.)

End-user scripts:
-----------------
* Qcolor.sh - set bulb color from a GUI.  (For now you will need to edit the script to add your bulb serial numbers and Q Station IP address.)
* Qmorse.sh - send a message in Morse code
* Qnotify.sh - notify the user about the success or failure of a command using bulb color
* Qprompt.sh - use with the Bash PROMPT_COMMAND environment variable to make a bulb turn green when a command succeeds and red when it fails (possibly useful for long-running commands)

Other files:
------------
* environment.conf - configuration data (needs to be set before any of the scripts will work)
* lib.sh - common library of functions used by end-user scripts
