# Flask SETUP for A bootstrap file
from flask import Flask, render_template

app = Flask(__name__, static_folder="static", static_url_path="/static")
modify_part = "https://d2x7rfuwi5c2f3.cloudfront.net/system-images/current-working.jpg"
plan_part = "https://d2x7rfuwi5c2f3.cloudfront.net/system-images/latter-working.jpg"

# Homepage
@app.route('/')
def home():
    return render_template('index.html',modifying = modify_part, planning = plan_part)

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

# 'work-single.html'
@app.route('/work-single')
def work_single():
    return render_template('work-single.html', modifying = modify_part, planning = plan_part)

# ALB: Target Group Health Check 
@app.route("/health")
def health():
    return "OK", 200

# execute Flask app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)