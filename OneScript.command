#!/usr/bin/python
# 0.0.1
import os, subprocess, shlex, datetime, sys

os.chdir(os.path.dirname(os.path.realpath(__file__)))

repos = [
    "https://github.com/corpnewt/EssentialsList",
    "https://github.com/corpnewt/Lilu-and-Friends",
    "https://github.com/corpnewt/CheckClover",
    "https://github.com/corpnewt/Plist-Tool",
    "https://github.com/corpnewt/CPU-Name",
    "https://github.com/corpnewt/Web-Driver-Toolkit",
    "https://github.com/corpnewt/APFS-Non-Verbose",
    "https://github.com/corpnewt/MountEFI",
    "https://github.com/corpnewt/USB-Installer-Creator",
    "https://github.com/corpnewt/Check-Some"
]

url = "https://raw.githubusercontent.com/corpnewt/OneScript/master/OneScript.command"

def run_command(comm, shell = False):
    c = None
    try:
        if shell and type(comm) is list:
            comm = " ".join(shlex.quote(x) for x in comm)
        if not shell and type(comm) is str:
            comm = shlex.split(comm)
        p = subprocess.Popen(comm, shell=shell, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        c = p.communicate()
        return (c[0].decode("utf-8", "ignore"), c[1].decode("utf-8", "ignore"), p.returncode)
    except:
        if c == None:
            return ("", "Command not found!", 1)
        return (c[0].decode("utf-8", "ignore"), c[1].decode("utf-8", "ignore"), p.returncode)

def _get_string(url):
    response = urlopen(url)
    CHUNK = 16 * 1024
    bytes_so_far = 0
    try:
        total_size = int(response.headers['Content-Length'])
    except:
        total_size = -1
    chunk_so_far = "".encode("utf-8")
    while True:
        chunk = response.read(CHUNK)
        bytes_so_far += len(chunk)
        #self._progress_hook(response, bytes_so_far, total_size)
        if not chunk:
            break
        chunk_so_far += chunk
    return chunk_so_far.decode("utf-8")

def get_version(text):
    try:
        return text.split("\n")[1][2:]
    except:
        return "Unknown"

def need_update(new, curr):
    for i in range(len(curr)):
        if int(new[i]) < int(curr[i]):
            return False
        elif int(new[i]) > int(curr[i]):
            return True
    return False

def check_update():
    # Checks against https://raw.githubusercontent.com/corpnewt/OneScript/master/OneScript.command to see if we need to update
    head("Checking for Updates")
    print(" ")
    with open(os.path.realpath(__file__), "r") as f:
        # Our version should always be the second line
        version = get_version(f.read())
    print(version)
    try:
        new_text = _get_string(url)
        new_version = get_version(new_text)
    except:
        # Not valid json data
        print("Error checking for updates (network issue)")
        return

    if version == new_version:
        # The same - return
        print("v{} is already current.".format(version))
        return
    # Split the version number
    try:
        v = version.split(".")
        cv = new_version.split(".")
    except:
        # not formatted right - bail
        print("Error checking for updates (version string malformed)")
        return

    if not need_update(cv, v):
        print("v{} is already current.".format(self.version))
        return

    # Update
    with open(os.path.realpath(__file__), "w") as f:
        f.write(new_text)

    # chmod +x, then restart
    run_command(["chmod", "+x", __file__])
    os.execv(__file__, sys.argv)

def cls():
   	os.system('cls' if os.name=='nt' else 'clear')

def head(text = "One Script", width = 55):
    cls()
    print("  {}".format("#"*width))
    mid_len = int(round(width/2-len(text)/2)-2)
    middle = " #{}{}{}#".format(" "*mid_len, text, " "*((width - mid_len - len(text))-2))
    if len(middle) > width+1:
        # Get the difference
        di = len(middle) - width
        # Add the padding for the ...#
        di += 3
        # Trim the string
        middle = middle[:-di] + "...#"
    print(middle)
    print("#"*width)

def custom_quit():
    head()
    print("by CorpNewt\n")
    print("Thanks for testing it out, for bugs/comments/complaints")
    print("send me a message on Reddit, or check out my GitHub:\n")
    print("www.reddit.com/u/corpnewt")
    print("www.github.com/corpnewt\n")
    # Get the time and wish them a good morning, afternoon, evening, and night
    hr = datetime.datetime.now().time().hour
    if hr > 3 and hr < 12:
        print("Have a nice morning!\n\n")
    elif hr >= 12 and hr < 17:
        print("Have a nice afternoon!\n\n")
    elif hr >= 17 and hr < 21:
        print("Have a nice evening!\n\n")
    else:
        print("Have a nice night!\n\n")
    exit(0)

def update():
    check_update()
    head("Updating Repos")
    print(" ")
    for repo in repos:
        if not os.path.exists(os.path.join(os.getcwd(), os.path.basename(repo))):
            # Doesn't exist - git clone that shiz
            print("Cloning {}...".format(os.path.basename(repo)))
            out = run_command(["git", "clone", repo])
            if out[2] == 0:
                print(out[0])
            else:
                print(out[1])
        else:
            # Exists - let's update it
            print("Updating {}...".format(os.path.basename(repo)))
            cwd = os.getcwd()
            os.chdir(os.path.basename(repo))
            out = run_command(["git", "pull"])
            if out[2] == 0:
                print(out[0])
            else:
                print(out[1])
            os.chdir(cwd)

def main():
    update()
    custom_quit()


if __name__ == '__main__':
    main()