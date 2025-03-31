import pandas as pd
import joblib
import argparse

def main(input_file, output_file, model_file="final_model.pkl"):
    """
    Predict cryptic hotspots using a pre-trained AdaBoost model.
    
    Parameters:
        input_file (str): Path to input CSV file with feature data.
        output_file (str): Path to save output CSV file with predictions.
        model_file (str): Path to the trained model file (default: final_model.pkl).
    """

    # Load model
    print(f" Loading model from: {model_file}")
    model = joblib.load(model_file)

    # Load input features
    print(f"📄 Reading input file: {input_file}")
    df = pd.read_csv(input_file)

    # Remove non-feature columns (e.g., PatchID)
    X = df.drop(columns=["PatchID"], errors="ignore")

    # Run prediction
    print("⚙️ Running prediction...")
    df["predicted_label"] = model.predict(X)
    df["predicted_proba"] = model.predict_proba(X)[:, 1]

    # Save output
    df.to_csv(output_file, index=False)
    print(f" Prediction saved to: {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Predict cryptic hotspots using a trained AdaBoost model.")
    parser.add_argument("input_file", help="Input CSV file with features (e.g., sample_features.csv)")
    parser.add_argument("output_file", help="Output CSV file with predictions (e.g., prediction_output.csv)")
    args = parser.parse_args()

    main(args.input_file, args.output_file)
