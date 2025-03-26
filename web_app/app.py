# Flask SETUP for A bootstrap file
from flask import Flask, render_template
from collections import defaultdict
import requests

app = Flask(__name__, static_folder="static", static_url_path="/static")

weather_api = "https://a98imz1co9.execute-api.eu-west-1.amazonaws.com/city"
modify_part = "https://d2x7rfuwi5c2f3.cloudfront.net/system-images/current-working.jpg"
plan_part = "https://d2x7rfuwi5c2f3.cloudfront.net/system-images/latter-working.jpg"

# Homepage
@app.route('/')
def home():

    weather_data = defaultdict(dict)
    cities = {"busan": {"latitude": 35.15774667299623, "longitude": 129.14471831319005},
              "london": {"latitude": 51.50566999671462, "longitude": -0.07538870441807435},
              "roma": {"latitude": 41.89042581491614, "longitude": 12.492220167804131}}
        
    for city, attributes in cities.items():
        weather_url = f'{weather_api}?latitude={attributes["latitude"]}&longitude={attributes["longitude"]}'
        response = requests.get(weather_url)

        if response.status_code == 200:
            info = response.json()

            weather_data[city]["min_temp"] = info.get("min","-")
            weather_data[city]["max_temp"] = info.get("max","-")
            weather_data[city]["cur_temp"] = info.get("current","-")
            weather_data[city]["it_is"]    = info.get("summary","Nothing Special")

        else:
            weather_data[city]["min_temp"] = "-"
            weather_data[city]["max_temp"] = "-"
            weather_data[city]["cur_temp"] = "-"
            weather_data[city]["it_is"]    = "-"

    return render_template('index.html',modifying = modify_part, planning = plan_part, weather = weather_data)

# 'work-single.html'
@app.route('/work-single')
def work_single():
    return render_template('work-single.html', modifying = modify_part, planning = plan_part)


# 'work-less.html'
@app.route('/work-less')
def work_less():
    #return "work-less is working!!!"
    return render_template('work-less.html', modifying = modify_part, planning = plan_part)

# 'about.html'
@app.route('/about')
def about():
    return render_template('about.html')

# 'blog.html'
@app.route('/blog')
def blog():
    return render_template('blog.html')

# 'contact.html' 
@app.route('/contact')
def contact():
    return render_template('contact.html')

# 'services.html'
@app.route('/services')
def services():
    return render_template('services.html')

# 'single.html'
@app.route('/single')
def single():
    return render_template('single.html')

# 'work.html'
@app.route('/work')
def work():
    return render_template('work.html')


# ALB: Target Group Health Check 
@app.route("/health")
def health():
    return "OK", 200

# execute Flask app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)