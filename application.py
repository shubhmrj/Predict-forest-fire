import pickle
from flask import Flask,request,jsonify,render_template
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler

application = Flask(__name__)
app=application

## import ridge regressor and standard scaler pickle
ridge_model=pickle.load(open('Models/ridge.pkl','rb'))
standard_scaler=pickle.load(open('Models/scaler.pkl','rb'))

# Enable CORS for GitHub Pages frontend
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route("/")
def index():
    return render_template('index.html')

@app.route('/predictdata',methods=['GET','POST'])
def predict_datapoint():
    if request.method=="POST":
        Temperature=float(request.form.get('Temperature'))
        RH = float(request.form.get('RH'))
        Ws = float(request.form.get('Ws'))
        Rain = float(request.form.get('Rain'))
        FFMC = float(request.form.get('FFMC'))
        DMC = float(request.form.get('DMC'))
        ISI = float(request.form.get('ISI'))
        Classes = float(request.form.get('Classes'))
        Region = float(request.form.get('Region'))

        new_data_scaled=standard_scaler.transform([[Temperature,RH,Ws,Rain,FFMC,DMC,ISI,Classes,Region]])
        result=ridge_model.predict(new_data_scaled)

        return render_template('home.html',results=result[0])

        
    else:
        return render_template('home.html')

if __name__=="__main__":
    app.run(host="0.0.0.0")

    @app.route('/api/predict', methods=['POST', 'OPTIONS'])
    def api_predict():
        if request.method == 'OPTIONS':
            return '', 204
        try:
            data = request.get_json()
            Temperature = float(data.get('Temperature'))
            RH = float(data.get('RH'))
            Ws = float(data.get('Ws'))
            Rain = float(data.get('Rain'))
            FFMC = float(data.get('FFMC'))
            DMC = float(data.get('DMC'))
            ISI = float(data.get('ISI'))
            Classes = float(data.get('Classes'))
            Region = float(data.get('Region'))
        
            new_data_scaled = standard_scaler.transform([[Temperature, RH, Ws, Rain, FFMC, DMC, ISI, Classes, Region]])
            result = ridge_model.predict(new_data_scaled)
        
            return jsonify({'prediction': float(result[0]), 'success': True})
        except Exception as e:
            return jsonify({'error': str(e), 'success': False}), 400