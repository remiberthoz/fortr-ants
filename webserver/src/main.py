import socket
import time
from http.client import HTTPConnection
from pathlib import Path
from flask import Flask, render_template, send_file

from plot_colony import plot_colony


def create_app(dat_path, gif_path):
    app = Flask(__name__)

    @app.route("/", methods=["GET"])
    def index():
        return render_template("index.html")

    @app.route("/generate", methods=["GET"])
    def generate():
        if dat_path.exists():
            dat_path.unlink()
        time.sleep(1)
        f = '/var/run/docker.sock'
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(f)
        conn = HTTPConnection('notused')
        conn.sock = s
        conn.request('POST', '/containers/smartants_simu/kill?signal=SIGUSR1')
        resp = conn.getresponse()
        time.sleep(3)
        plot_colony(dat_path, gif_path)
        return f'<img id="resultgif" src="/result.gif?t={time.time():.0f}">'

    @app.route("/result.gif")
    def results():
        return send_file(gif_path, mimetype='image/gif')

    return app


def main():
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('dat_path', type=Path)
    parser.add_argument('gif_path', type=Path)
    args = parser.parse_args()
    app = create_app(args.dat_path, args.gif_path)
    print("Starting webserver...")
    app.run(host='0.0.0.0', debug=True)


if __name__ == "__main__":
    main()
