from flask import Flask, send_from_directory

app = Flask(__name__, static_folder='build/web')

@app.route('/')
def serve():
    return send_from_directory('build/web', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('build/web', path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
