# belleds
Simple utilities for working with the Belleds Q Station and color-changing light bulbs.

Edit environment.conf to reflect your Q Station's IP address.

Requirements:
-------------
You will need to install the jq package (for JSON parsing) to use these scripts.  (In Ubuntu, this is 'sudo apt-get install jq'.)
You will also need a firmware revision on the Q that does not lock up when the bulb list is queried.  Currently this seems to be *only* 1.0.00_r341.

End-user scripts:
-----------------
* Qcolor.sh - set bulb color from a GUI.  (For now you will need to edit the script to add your bulb serial numbers and Q Station IP address.)
* Qmorse.sh - send a message in Morse code
* Qnotify.sh - notify the user about the success or failure of a command using bulb color
* Qprompt.sh - use with the Bash PROMPT_COMMAND environment variable to make a bulb turn green when a command succeeds and red when it fails (possibly useful for long-running commands)
* Qname.sh - change the name of a bulb

Other files:
------------
* environment.conf - configuration data (needs to be set before any of the scripts will work)
* lib.sh - common library of functions used by end-user scripts

Bugs:
-----
* Quoting spaces on bulb names such that bash and zenity play nicely together is giving me ulcers.  For now it replaces spaces with underscores, which is suboptimal.
