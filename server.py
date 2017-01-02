import zmq
import argparse
import json

import os

import numpy as np
import yaml
from flask import Flask, send_from_directory, jsonify, Response, redirect
from flask import request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

data_handlers = {}
index_map = {}


@app.route('/api/translate/')
def transate():
    options = request.args
    src = options.get('src')
    print("src", src)
    sock.send(json.dumps({"src" : src}))
    result = sock.recv()
    return result

# send everything from client as static content
@app.route('/client/<path:path>')
def send_static(path):
    """ serves all files from ./client/ to ``/client/<path:path>``

    :param path: path from api call
    """
    return send_from_directory('client/', path)



@app.route('/')
def hello_world():
    """
    :return: "hello world"
    """
    return redirect('client/index.html')

parser = argparse.ArgumentParser()
parser.add_argument("--nodebug", default=False)
parser.add_argument("--port", default="8888")
parser.add_argument("--nocache", default=False)
parser.add_argument("-dir", type=str, default=os.path.abspath('data'))

if __name__ == '__main__':
    args = parser.parse_args()
    # create_data_handlers(args.dir)

    # print args

    # ZeroMQ Context
    context = zmq.Context()

    # Define the socket using the "Context"
    sock = context.socket(zmq.REQ)
    sock.connect("tcp://127.0.0.1:5556")
    
    app.run(port=int(args.port), debug=not args.nodebug, host="0.0.0.0")
