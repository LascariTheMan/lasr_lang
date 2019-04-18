import subprocess
import sys
import os

paths = ["C:\\Users", "C:\Program Files (x86)"]
cloud_sdk = None
apikey_file = None

def get_paths():
    for path in paths:
        found = check_path(path)
        if found:
            break

def check_path(path):
    for root, directory, fil in os.walk(path):
        found = check_folders(root, directory)
        if found:
            return True

def check_folders(root, directory):
    global cloud_sdk, apikey_file
    for folder in directory:
        if folder == "Cloud SDK":
            cloud_sdk = os.path.join(root, folder)
        if folder == "lasr_lang_apikey":
            apikey_file = os.path.join(root, folder) + "\\apikey.json"
        if cloud_sdk and apikey_file:
            return True

try:
    f = open("paths.txt","w+")
    lines = f.readlines()
    cloud_sdk = lines[0].rstrip("\n")
    apikey_file = lines[1].rstrip("\n")
except (IndexError, FileNotFoundError) as e:
    get_paths()
    f.write(cloud_sdk + "\n" + apikey_file)

print(subprocess.call(["set", "GOOGLE_APPLICATION_CREDENTIALS=" + apikey_file, "&", "gcloud", "auth", "application-default", "print-access-token"], shell=True, cwd=cloud_sdk))
sys.stdout.flush()