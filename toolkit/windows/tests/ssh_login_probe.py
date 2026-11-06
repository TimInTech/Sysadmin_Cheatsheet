"""CI-only local authentication and session expiry probe; never prints credentials."""
import os
import socket
import sys
import time

import paramiko


def connect(password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect("127.0.0.1", port=int(os.environ["TOOLKIT_TEST_PORT"]),
                   username=os.environ["TOOLKIT_TEST_USER"], password=password,
                   allow_agent=False, look_for_keys=False, timeout=5, auth_timeout=5,
                   banner_timeout=5)
    return client


deadline = time.monotonic() + 20
while True:
    try:
        client = connect(os.environ["TOOLKIT_TEST_PASSWORD"])
        break
    except (socket.error, paramiko.SSHException):
        if time.monotonic() >= deadline:
            raise RuntimeError("SSH server did not accept a valid login in time") from None
        time.sleep(0.2)

try:
    try:
        bad_client = connect(os.environ["TOOLKIT_TEST_PASSWORD"] + "wrong")
    except paramiko.AuthenticationException:
        pass
    else:
        bad_client.close()
        raise RuntimeError("Incorrect password was accepted")
    _, stdout, _ = client.exec_command("ping -n 120 127.0.0.1", timeout=5)
    print("AUTH_AND_SESSION_OK", flush=True)
    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        transport = client.get_transport()
        if stdout.channel.closed or transport is None or not transport.is_active():
            print("SESSION_CLOSED", flush=True)
            sys.exit(0)
        time.sleep(0.1)
    raise RuntimeError("Open SSH session survived its deadline")
finally:
    client.close()
