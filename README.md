
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

