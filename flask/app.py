from flask import Flask, render_template, request
import requests

app = Flask(__name__)

#OpenWeatherMap API key
API_KEY = '4e559ae28c374d1fa5cadd65589a7551'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/weather', methods=['POST'])
def weather():
    city = request.form['city']
    if city:
        weather_url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"
        response = requests.get(weather_url)
        data = response.json()

        if data["cod"] == "404":
            return render_template('index.html', error="City not found.")
        else:
            weather_info = {
                "city": data["name"],
                "temperature": data["main"]["temp"],
                "description": data["weather"][0]["description"],
                "icon": data["weather"][0]["icon"]
            }
            return render_template('weather.html', weather=weather_info)
    else:
        return render_template('index.html', error="Please enter a city name.")

if __name__ == '__main__':
    app.run(debug=True)
