import subprocess
import sys
import os

apikey_file = "apikey.json"

print(subprocess.call(["set", "GOOGLE_APPLICATION_CREDENTIALS=" + apikey_file, "&", "gcloud", "auth", "application-default", "print-access-token"], shell=True))
sys.stdout.flush()