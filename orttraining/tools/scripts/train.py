import re
import shlex
import subprocess
import sys

# Only allow arguments made of a safe character set to avoid argument injection.
_SAFE_ARG = re.compile(r"^[A-Za-z0-9_./:=,@+-]+$")


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    for arg in argv:
        if not _SAFE_ARG.match(arg):
            print(f"Invalid argument: {arg}", file=sys.stderr)
            sys.exit(1)

    cmd = ["/workspace/onnxruntime_training_bert", *argv]
    print(shlex.join(cmd))
    subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
