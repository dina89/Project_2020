from flask import Flask, render_template
from prometheus_client import start_http_server, Counter, Summary

app = Flask(__name__)


call_metric = Counter('opsschool_monitor_hello_whale_main_count', 'Number of visits to main', [ "service", "endpoint" ])
time_metric = Summary('opsschool_monitor_hello_whale_request_processing_seconds', 'Time spent processing request', [ "method" ])

hello_whale_timer = time_metric.labels(method="hello_whale")
@app.route('/')
@hello_whale_timer.time()
def hello_whale():
    call_metric.labels(service='opsschool_hello_whale', endpoint='main').inc(1)
    return render_template("whale_hello.html")

if __name__ == '__main__':
    start_http_server(5001)
    app.run(debug=False, host='0.0.0.0')