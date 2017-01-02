import zmq
import sys
import json

context = zmq.Context()

# Define the socket using the "Context"
sock = context.socket(zmq.REQ)
sock.connect("tcp://127.0.0.1:5556")

# Send a "message" using the socket
sock.send(json.dumps({"src" : " ".join(sys.argv[1:])}))
print sock.recv()
