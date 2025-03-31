#  Cryptic Site Prediction

This repository provides a Jupyter Notebook and a pre-trained machine learning model to predict cryptic hotspots using structure-derived features.

##  Files

- `predict_cryptic_hotspot.ipynb`: Jupyter Notebook for prediction
- `final_model.pkl`: Pre-trained AdaBoost model
- `sample_features.csv`: Example input features
- `requirements.txt`: Required Python packages

##  How to Use

1. Clone the repository or download the files
2. Open the notebook in Jupyter
3. Replace `sample_features.csv` with your own file (same structure)
4. Run all cells to generate predictions

##  Requirements
pandas
scikit-learn
joblib
matplotlib
seaborn

##  Predict via CLI (Linux)

You can also use `cryptothml.py` to run predictions from the command line:

**`$python3 cryptothml.py sample_features.csv prediction_output.csv`**
