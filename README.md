# Default of Credit Card Clients - Statistical Analysis and Modeling

A comprehensive statistical regression project analyzing credit card default prediction using logistic regression in R.

## 📋 Project Overview

This project analyzes the "Default of Credit Card Clients in Taiwan" dataset to predict credit card payment defaults. The analysis employs logistic regression modeling with systematic feature selection to identify key predictors of credit risk.

**Course:** Statistical Regression  
**Institution:** African Institute for Mathematical Sciences (AIMS Rwanda, Kigali)  
**Academic Year:** 2024/2025  
**Instructor:** Prof. Fabrizio Ruggeri  
**Date:** November 2024

## 👥 Group 6 Members

- Olusola Timothy OGUNDEPO
- Yan Kevin ZE
- Arnaud FOUBEUDA BOZAHBE
- Consolee NISINGIZWE

## 🎯 Objectives

- Perform exploratory data analysis on credit card default data
- Build and evaluate logistic regression models for binary classification
- Apply systematic feature selection techniques to identify optimal predictors
- Assess model performance using industry-standard metrics
- Provide interpretable insights for credit risk assessment

## 📊 Dataset

**Source:** Default of Credit Card Clients dataset (Taiwan)  
**Location:** `datasets/default of credit card clients.xls`

**Features:** 24 variables including:
- Demographic information (age, sex, education, marriage)
- Credit data (credit limit)
- Payment history (PAY_0 to PAY_6)
- Bill amounts (BILL_AMT1 to BILL_AMT6)
- Payment amounts (PAY_AMT1 to PAY_AMT6)

**Target Variable:** Default payment next month (binary: 0 = No, 1 = Yes)

## 🔬 Methodology

### 1. Data Preparation
- Data loading and cleaning
- Missing value analysis
- Removal of non-predictive features (ID column)

### 2. Exploratory Data Analysis
- Target variable distribution analysis (Class imbalance: ~78% non-default, ~22% default)
- Relationship exploration between features and default status
- Visualization of key predictors (payment status, age, credit limit, education, marriage status)

### 3. Feature Selection
- Initial full model with all 23 features
- Individual feature AIC evaluation
- Forward stepwise selection based on AIC criteria
- **Final model:** 18 selected features

### 4. Model Training & Validation
- Stratified train-test split (70/30) to preserve class balance
- Logistic regression with selected features
- Model diagnostics (residual plots, Q-Q plots)

### 5. Model Evaluation
- Confusion matrix analysis
- Performance metrics with confidence intervals
- ROC curve and AUC calculation

## 📈 Key Results

### Model Performance Metrics

| Metric | Value | Interpretation |
|--------|-------|----------------|
| **Accuracy** | 81.20% | Overall correct predictions |
| **Sensitivity (Recall)** | 24.72% | Proportion of actual defaults identified |
| **Specificity** | 97.23% | Proportion of non-defaults identified |
| **Precision** | 71.72% | Accuracy of default predictions |
| **Balanced Accuracy** | 60.98% | Performance accounting for class imbalance |
| **AUC** | 0.7250 | Model discrimination ability |

### Selected Features (18 total)
The final model includes:
- Payment status indicators (PAY_0, PAY_2, PAY_3, PAY_5)
- Payment amounts (PAY_AMT1-6)
- Bill amounts (BILL_AMT1-3)
- Demographic variables (LIMIT_BAL, MARRIAGE, SEX, EDUCATION, AGE)

## 🛠️ Technologies & Tools

### R Libraries
- `tidyverse` - Data manipulation and visualization
- `readxl` - Excel file import
- `corrplot` - Correlation visualization
- `caret` - Machine learning and model evaluation
- `pROC` - ROC curve analysis
- `gridExtra` - Multiple plot arrangement

### Development Environment
- R Markdown for reproducible analysis
- LaTeX for professional report generation
- RStudio project structure

## 📁 Project Structure

```
root/
├── SR_EQ_C_G6.Rmd              # Main R Markdown analysis file
├── SR_EQ_C_G6.pdf              # Compiled analysis report
├── SR_EQ_P_G6.pdf              # Presentation slides
├── datasets/
│   └── default of credit card clients.xls
├── Report/
│   ├── SR_EQ_R_G6.tex          # LaTeX report source
│   └── images/                  # Generated figures
├── extract_images_exact.R       # Image extraction utility
├── packages                     # R package dependencies
├── Final-group-project.Rproj   # RStudio project file
└── README.md                    # This file
```

## 🚀 Getting Started

### Prerequisites
- R (version 4.0 or higher recommended)
- RStudio (optional but recommended)
- Required R packages (see Technologies section)

### Installation

1. Clone or download this repository
2. Open `Final-group-project.Rproj` in RStudio
3. Install required packages:

```r
install.packages(c("tidyverse", "readxl", "corrplot", "caret", "pROC", "gridExtra"))
```

### Running the Analysis

1. Open `SR_EQ_C_G6.Rmd` in RStudio
2. Ensure the dataset is in the `datasets/` folder
3. Click "Knit" to generate the full report (PDF)
4. Or run chunks interactively for step-by-step exploration

## 📝 Key Findings

1. **Class Imbalance Challenge:** The dataset exhibits significant class imbalance (78:22 ratio), requiring stratified sampling and careful metric selection.

2. **Payment History Dominance:** Payment status variables (PAY_0, PAY_2, PAY_3, PAY_5) emerged as strong predictors, indicating recent payment behavior is crucial for default prediction.

3. **High Specificity, Low Sensitivity:** The model excels at identifying non-defaulters (97.23% specificity) but struggles with defaulters (24.72% sensitivity), typical for imbalanced datasets.

4. **Trade-off Consideration:** The model prioritizes minimizing false positives (incorrectly predicting default) at the cost of missing some true defaults - appropriate for conservative credit risk assessment.

## 🔍 Model Interpretation

The logistic regression coefficients reveal:
- **Risk Factors** (positive coefficients): Increase default probability
- **Protective Factors** (negative coefficients): Decrease default probability

Odds ratios provide interpretable effect sizes, with confidence intervals indicating statistical reliability.

## 📚 Documentation

- **Main Analysis:** `SR_EQ_C_G6.Rmd` contains detailed comments explaining each step
- **Technical Report:** `Report/SR_EQ_R_G6.tex` provides formal mathematical exposition
- **Presentation Slides:** `SR_EQ_P_G6.pdf` summarizes key points for oral presentation

## 📄 License

This project is submitted for academic evaluation at AIMS Rwanda. Please respect academic integrity policies if referencing this work.

## 🙏 Acknowledgments

- Prof. Fabrizio Ruggeri for guidance and instruction
- AIMS Rwanda for providing the learning environment
- Original dataset contributors from Taiwan

---

**Note:** This project demonstrates the application of statistical regression techniques to real-world credit risk assessment, balancing statistical rigor with practical interpretability.
