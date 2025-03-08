# Flask SETUP for A bootstrap file
from flask import Flask, render_template

app = Flask(__name__)

# Homepage
@app.route('/')
def home():
    return render_template('index.html')

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
    return render_template('work-single.html')

# execute Flask app
if __name__ == '__main__':
    app.run(debug=True)
