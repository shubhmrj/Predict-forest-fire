
# Predict-Forest-Fire

An end-to-end forest-fire prediction project using the Algerian Forest Fires dataset. This repository contains data, notebooks for EDA and model training, a minimal Flask prototype UI (`application.py` + `templates/`), and saved model artifacts (`Models/`). The goal is reproducible analysis, transparent mathematics, and an easy path to deployment.

**Table of Contents**

- Features
- Dataset
- Repository layout
- Quick start
- Model training & mathematics
- Visualizations (cost function)
- User interaction (UI & API)
- Deployment (AWS Elastic Beanstalk)
- Next steps

## Features

- Binary classification: predict `fire` or `not fire` from weather and FWI indices.
- Notebooks for EDA and feature engineering.
- Scripts for plotting training diagnostics (`scripts/plot_cost_function.py`).
- Prototype Flask UI for manual testing and demos.

## Dataset — Algerian Forest Fires

Short summary:

- Instances: 244 (122 per region: Bejaia and Sidi Bel-abbes)
- Period: June — September 2012
- Inputs: 11 attributes (weather + FWI components)
- Output: `Classes` — two labels (`fire`, `not fire`) — 138 fire, 106 not fire

Attribute list:

1. Date — DD/MM/YYYY
2. Temp — temperature at noon (°C)
3. RH — relative humidity (%)
4. Ws — wind speed (km/h)
5. Rain — daily rainfall (mm)
6. FFMC — Fine Fuel Moisture Code
7. DMC — Duff Moisture Code
8. DC — Drought Code
9. ISI — Initial Spread Index
10. BUI — Buildup Index
11. FWI — Fire Weather Index
12. Classes — `fire` / `not fire`

CSV files are stored in the `Datasets/` folder.

## Repository layout

- `application.py` — Flask app entrypoint (prototype UI + endpoints).
- `Datasets/` — raw CSV data.
- `Notebooks/` — `EDA_and_FeatueEngineering.ipynb`, `model_training.ipynb`.
- `Models/` — exported scalers and trained model pickles (e.g., `ridge.pkl`, `scaler.pkl`).
- `templates/` — `home.html`, `index.html` for the Flask UI.
- `scripts/plot_cost_function.py` — demo script to create `docs/cost_function.png`.
- `requirement.txt` — runtime dependencies.

## Quick start

1. Create and activate a virtual environment, then install dependencies:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirement.txt
pip install numpy pandas matplotlib scikit-learn
```

2. Generate the example cost plot (saved at `docs/cost_function.png`):

```powershell
python scripts/plot_cost_function.py
```

3. Run the Flask prototype locally:

```powershell
python application.py
```

Open http://localhost:5000 to use the web UI.

## Model training & mathematics

The notebooks contain the implementation details. Below are concise mathematical notes that match the code patterns used in the repository.

Problem: binary classification (predicting `fire` / `not fire`). A typical approach here is logistic regression or any classifier from scikit-learn.

Logistic regression model:

Hypothesis (sigmoid):
$$
h_{\theta}(x) = \sigma(\theta^T x) = \frac{1}{1 + e^{-\theta^T x}}
$$

Cost (log-loss / cross-entropy):
$$
J(\theta) = -\frac{1}{m} \sum_{i=1}^{m} \Big[y^{(i)}\log h_{\theta}(x^{(i)}) + (1-y^{(i)})\log(1 - h_{\theta}(x^{(i)}))\Big]
$$

Gradient (batch):
$$
\nabla_{\theta} J(\theta) = \frac{1}{m} X^T (h_{\theta}(X) - y)
$$

Update rule (gradient descent):
$$
\theta := \theta - \alpha \nabla_{\theta} J(\theta)
$$

Regularization (L2 ridge): add $\frac{\lambda}{2m} \|\theta\|_2^2$ to the cost and $\frac{\lambda}{m} \theta$ to the gradient (excluding intercept).

Notes on feature scaling:

- Many models (especially regularized linear models) require standardized features. Use a scaler: $x' = \frac{x - \mu}{\sigma}$ where $\mu$ is the training mean and $\sigma$ the std.
- Scalers are saved in `Models/` (see `scaler.pkl`). Always apply the same scaler at inference.

Model choices in `model_training.ipynb` include `Ridge`, `LogisticRegression`, and tree-based classifiers. Each notebook cell shows training, cross-validation, and how models are exported with `joblib`.

## Visualizations — cost function

The repository includes `scripts/plot_cost_function.py` that generates a demonstration cost-vs-iterations chart and saves it to `docs/cost_function.png`.

To plot the actual training loss from your training loop:

1. In your training code, append the training loss per epoch to a list `loss_history` and save it as JSON or pickle.
2. Update `scripts/plot_cost_function.py` to load that file and plot the recorded values.

Example snippet (save inside training loop):

```python
loss_history.append(current_loss)
with open('Models/loss_history.json','w') as f:
    json.dump(loss_history, f)
```

Then modify the plotting script to load `Models/loss_history.json`.

## User interaction (UI & API)

The Flask prototype provides a simple form-based UI and can be extended to an API. Example interactions:

- UI: open `http://localhost:5000` to enter feature values and get a prediction.
- API (example cURL):

```bash
curl -s -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"Temp":30,"RH":40,"Ws":10,"Rain":0,"FFMC":85.3,"DMC":10.5,"DC":50.2,"ISI":3.2,"BUI":12.1,"FWI":6.8}'
```

The endpoint should load `Models/scaler.pkl` and `Models/<model>.pkl`, transform inputs, and return JSON:

```json
{ "prediction": "fire", "probability": 0.87 }
```

If you want, I can update `application.py` to include a `/predict` JSON API that accepts either single records or batches.

## Deployment — AWS Elastic Beanstalk

Checklist for a production-ready EB deployment:

1. Ensure `requirements.txt` includes runtime packages (Flask, gunicorn, scikit-learn, pandas, etc.).
2. Add a `Procfile` for gunicorn (example):

```
web: gunicorn application:app
```

3. Ensure `Models/` contains the serialized model(s) you want to serve and that the model files are included in your AMI/deploy bundle or downloaded at startup.
4. Use GitHub Actions + `aws-actions/configure-aws-credentials` and `aws-actions/elastic-beanstalk-deploy` for CI/CD. Store AWS credentials in GitHub Secrets.

Manual EB quick-commands (EB CLI):

```powershell
pip install awsebcli
eb init -p python-3.8 my-forest-fire-app --region us-east-1
eb create my-forest-fire-env
eb deploy
```

Replace `my-forest-fire-app` and `my-forest-fire-env` with your names. For GitHub Actions, tell me the branch and EB app/env names and I will add a deploy workflow.

## Next steps I can implement for you

- Add a reproducible GitHub Actions workflow that deploys to Elastic Beanstalk on push to `main`.
- Add a `Procfile` and minimal production WSGI settings (`gunicorn`) and health checks.
- Add a `/predict` JSON API and example Postman collection.
- Extend the notebooks to save `loss_history` and automatically generate training diagnostics at the end of a run.

If you'd like any of the above, tell me which item to do next (for example: "Add Actions workflow to deploy from `main` to EB app `my-app` env `my-env`").

---
*README autogenerated/expanded by repository assistant.*

# Predict-Forest-Fire

Predict-Forest-Fire is a small project to explore, model, and deploy a forest-fire prediction solution using the Algerian Forest Fires dataset. The repository includes data, notebooks for EDA and model training, a simple Flask app entrypoint (`application.py`) and templates for a web UI.

## Dataset — Algerian Forest Fires Dataset

Data Set Information:

- The dataset includes 244 instances from two regions of Algeria: Bejaia (northeast) and Sidi Bel-abbes (northwest).
- 122 instances for each region.
- Period: June 2012 to September 2012.
- 11 input attributes and 1 output attribute (`Classes`).
- Instances classified into `fire` (138) and `not fire` (106).

Attribute Information:

1. Date: (DD/MM/YYYY) — day/month/year (2012). Months from June to September.
2. Temp: temperature at noon (max) in Celsius: 22 to 42.
3. RH: Relative Humidity in %: 21 to 90.
4. Ws: Wind speed in km/h: 6 to 29.
5. Rain: total daily rainfall in mm: 0 to 16.8.
6. Fine Fuel Moisture Code (FFMC): 28.6 to 92.5.
7. Duff Moisture Code (DMC): 1.1 to 65.9.
8. Drought Code (DC): 7 to 220.4.
9. Initial Spread Index (ISI): 0 to 18.5.
10. Buildup Index (BUI): 1.1 to 68.
11. Fire Weather Index (FWI): 0 to 31.1.
12. Classes: two classes — `fire` and `not fire`.

The dataset files are included in the `Datasets/` folder:

- `Datasets/Algerian_forest_fires_dataset.csv`
- `Datasets/algerian_forst_fires_updated_datatset.csv`

## Project structure

- `application.py` — Flask app entrypoint (serves templates in `templates/`).
- `Datasets/` — raw CSV dataset files.
- `Models/` — place trained model artifacts here.
- `Notebooks/` — analysis and model-training notebooks (`EDA_and_FeatueEngineering.ipynb`, `model_training.ipynb`).
- `templates/` — HTML templates used by the app (`home.html`, `index.html`).
- `requirement.txt` — Python dependencies.

## Installation

1. Install Python 3.8+.
2. Create and activate a virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirement.txt
```

3. Run the app locally:

```powershell
python application.py
```

Open http://localhost:5000 in a browser (or check the Flask output for the exact URL).

## Notebooks and training

- Use `Notebooks/EDA_and_FeatueEngineering.ipynb` for exploratory data analysis and feature engineering.
- Use `Notebooks/model_training.ipynb` to train models and export artifacts to `Models/`.

## Deployment — AWS Elastic Beanstalk (summary)

This repository is suitable for deployment to AWS Elastic Beanstalk using a simple Python (Flask) platform. A typical automated pipeline (GitHub -> AWS) is:

1. Add any required production files: `requirements.txt`, and if needed a `Procfile` or `Dockerfile` depending on chosen deployment method.
2. Configure an Elastic Beanstalk application and environment (EB CLI or AWS Console).
3. Store `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` as GitHub repository Secrets.
4. Use a GitHub Actions workflow to deploy on push to the main branch (or use the official `aws-actions/elastic-beanstalk-deploy` action). Example high-level steps:

- Checkout repository
- Set up Python environment
- Install dependencies
- Run tests (optional)
- Deploy to Elastic Beanstalk using stored AWS credentials

For a quick manual EB deployment using the EB CLI:

```powershell
pip install awsebcli
eb init -p python-3.8 my-forest-fire-app --region us-east-1
eb create my-forest-fire-env
eb deploy
```

Replace `my-forest-fire-app`, `my-forest-fire-env`, and the region as appropriate. For CI/CD, prefer using GitHub Actions with secrets rather than embedding credentials.

## Dataset citation / source

The dataset used in this project is the Algerian Forest Fires dataset (June–September 2012). The CSV copies are stored in the `Datasets/` folder.

## Notes

- The repository contains minimal app scaffolding. Review `application.py` and `templates/` to adapt the UI or APIs to your needs.
- If you want, I can add a ready-to-use GitHub Actions workflow for automatic EB deployment — tell me which branch and EB application/environment names to target.

## License & Contact

This repository does not include a license file. Add one if you plan to open-source the code. For questions or help, open an issue or contact the repo owner.

