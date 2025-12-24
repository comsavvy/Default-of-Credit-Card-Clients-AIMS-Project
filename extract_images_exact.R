#!/usr/bin/env Rscript
# Extract images from R Markdown using EXACT code from Rmd file
# This ensures 100% match with what appears in the PDF

library(tidyverse)
library(readxl)
library(corrplot)
library(caret)
library(pROC)
library(gridExtra)

# Load and prepare data
df <- read_excel("datasets/default of credit card clients.xls", skip = 1)
df <- df |> select(-ID)
df$`default payment next month` <- factor(df$`default payment next month`, levels = c(0, 1))

# Create images directory
dir.create("Report/images", showWarnings = FALSE)

# ============================================================================
# 1. TARGET VARIABLE DISTRIBUTION - EXACT FROM RMD
# ============================================================================
png("Report/images/01_target_distribution.png", width = 800, height = 600)
df |> ggplot(aes(x = factor(`default payment next month`))) +
  geom_bar(fill = "steelblue", width = 0.5) +
  labs(title = "Distribution of Default Payment",
       x = "Default (0 = No, 1 = Yes)",
       y = "Count") +
  theme_minimal()
dev.off()
print("✓ Saved: 01_target_distribution.png")

# ============================================================================
# 2. EXPLORATORY DATA ANALYSIS - EXACT 6-PANEL FROM RMD
# ============================================================================
png("Report/images/02_exploratory_analysis.png", width = 1200, height = 800)

# Create a few exploratory plots
par(mfrow = c(2, 3))

# 1. Payment Status (PAY_0) vs Default
df_plot <- df |> 
  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default"))) |> 
  group_by(PAY_0, `default payment next month`) |> 
  summarise(Count = n(), .groups = "drop")

plot_pay0 <- ggplot(df_plot, aes(x = factor(PAY_0), y = Count, fill = `default payment next month`)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  labs(title = "Payment Status vs Default",
       x = "Payment Status (Month 0)",
       y = "Number of Customers",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() + theme(axis.text.x = element_text(angle = 45))

# 2. Age vs Default (box plot)
plot_age <- ggplot(df |>  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default"))), 
                   aes(x = `default payment next month`, y = AGE, fill = `default payment next month`)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Age Distribution by Default Status",
       x = "Outcome",
       y = "Age",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() +
  theme(legend.position = "none")

# 3. Credit Limit vs Default
plot_limit <- ggplot(df |>  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default"))), 
                     aes(x = `default payment next month`, y = LIMIT_BAL, fill = `default payment next month`)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Credit Limit by Default Status",
       x = "Outcome",
       y = "Credit Limit",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() +
  theme(legend.position = "none")

# 4. Payment Amount vs Default
plot_payamt <- ggplot(df |>  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default"))) |> 
                       filter(PAY_AMT1 < 100000), # Remove extreme outliers for better visualization
                     aes(x = `default payment next month`, y = PAY_AMT1, fill = `default payment next month`)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Payment Amount (PAY_AMT1) by Default Status",
       x = "Outcome",
       y = "Payment Amount (Month 1)",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() +
  theme(legend.position = "none")

# 5. Education vs Default
df_edu <- df |> 
  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default")),
         EDUCATION = factor(EDUCATION, levels = c(0, 1, 2, 3, 4, 5, 6), 
                           labels = c("Unknown", "Graduate", "University", "High School", "Other", "Unknown2", "Unknown3"))) |> 
  group_by(EDUCATION, `default payment next month`) |> 
  summarise(Count = n(), .groups = "drop")

plot_edu <- ggplot(df_edu, aes(x = EDUCATION, y = Count, fill = `default payment next month`)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  labs(title = "Education Level vs Default",
       x = "Education Level",
       y = "Number of Customers",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 6. Marriage Status vs Default
df_marr <- df |> 
  mutate(`default payment next month` = factor(`default payment next month`, labels = c("No Default", "Default")),
         MARRIAGE = factor(MARRIAGE, levels = c(0, 1, 2, 3), 
                          labels = c("Unknown", "Married", "Single", "Divorced"))) |> 
  group_by(MARRIAGE, `default payment next month`) |> 
  summarise(Count = n(), .groups = "drop")

plot_marr <- ggplot(df_marr, aes(x = MARRIAGE, y = Count, fill = `default payment next month`)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  labs(title = "Marriage Status vs Default",
       x = "Marriage Status",
       y = "Number of Customers",
       fill = "Outcome") +
  scale_fill_manual(values = c("No Default" = "#27ae60", "Default" = "#e74c3c")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Combine plots
grid.arrange(plot_pay0, plot_age, plot_limit, plot_payamt, plot_edu, plot_marr, ncol = 3)
dev.off()
print("✓ Saved: 02_exploratory_analysis.png")

# ============================================================================
# 3. AIC PROGRESSION - EXACT FROM RMD
# ============================================================================
# Prepare models for AIC progression
full_model <- glm(`default payment next month` ~ .,
                  data = df,
                  family = binomial(link = "logit"))

initial_model <- glm(`default payment next month` ~ PAY_0, data = df, family = binomial(link = "logit"))
step_model <- step(initial_model, scope = list(upper = full_model), direction = "forward", trace = 0)

selected_features <- names(coef(step_model))[-1]
aics <- numeric(length(selected_features))
aics[1] <- AIC(initial_model)

for(i in 2:length(selected_features)) {
  formula_str <- paste("`default payment next month` ~", 
                       paste(selected_features[1:i], collapse = " + "))
  temp_model <- glm(as.formula(formula_str), data = df, 
                    family = binomial(link = "logit"))
  aics[i] <- AIC(temp_model)
}

png("Report/images/03_aic_progression.png", width = 1000, height = 600)
feature_progression_viz <- data.frame(
  Step = seq_along(selected_features),
  Features_Count = seq_along(selected_features),
  AIC = aics
)

ggplot(feature_progression_viz, aes(x = Features_Count, y = AIC)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 3) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.2, color = "gray") +
  labs(title = "AIC Progression Through Forward Feature Selection",
       x = "Number of Features Added",
       y = "AIC Value",
       subtitle = "Demonstrates diminishing returns as features are progressively added") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "gray40"),
        axis.text = element_text(size = 10))
dev.off()
print("✓ Saved: 03_aic_progression.png")

# ============================================================================
# 4. COEFFICIENT PLOT - EXACT FROM RMD
# ============================================================================
coef_summary <- coef(step_model)
ci_matrix <- confint(step_model, level = 0.95)

model_coef <- data.frame(
  Feature = names(coef_summary),
  Coefficient = coef_summary,
  CI_Lower = ci_matrix[, 1],
  CI_Upper = ci_matrix[, 2]
) |>
  filter(Feature != "(Intercept)") |>
  arrange(Coefficient) |>
  mutate(Feature = factor(Feature, levels = Feature),
         Effect_Type = ifelse(Coefficient > 0, "Risk Factor", "Protective Factor"))

png("Report/images/04_coefficients.png", width = 1000, height = 800)
ggplot(model_coef, aes(x = Coefficient, y = Feature, fill = Effect_Type)) +
  geom_col(width = 0.6, alpha = 0.8) +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper), height = 0.3, color = "black", linewidth = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", linewidth = 1) +
  scale_fill_manual(values = c("Risk Factor" = "#e74c3c", "Protective Factor" = "#27ae60")) +
  labs(title = "Model Coefficients with 95% Confidence Intervals",
       x = "Coefficient Value",
       y = "Feature",
       fill = "Effect Type",
       subtitle = "Red: Increases default risk | Green: Decreases default risk | Error bars show 95% CI") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "gray40"),
        axis.text.y = element_text(size = 9),
        axis.text.x = element_text(size = 10),
        legend.position = "bottom")
dev.off()
print("✓ Saved: 04_coefficients.png")

# ============================================================================
# 5. CONFUSION MATRIX - EXACT FROM RMD
# ============================================================================
set.seed(123)
train_idx <- createDataPartition(df$`default payment next month`, p = 0.7, list = FALSE)
train_data <- df[train_idx, ]
test_data <- df[-train_idx, ]

train_model <- glm(`default payment next month` ~ PAY_0 + PAY_2 + PAY_3 + PAY_5 + 
                     LIMIT_BAL + PAY_AMT1 + MARRIAGE + SEX + EDUCATION + 
                     AGE + PAY_AMT2 + PAY_AMT4 + PAY_AMT3 + PAY_AMT5 + BILL_AMT1 + 
                     PAY_AMT6 + BILL_AMT2 + BILL_AMT3,
                   data = train_data,
                   family = binomial(link = "logit"))

pred_prob <- predict(train_model, newdata = test_data, type = 'response')
pred_class <- ifelse(pred_prob > 0.5, 1, 0)

actual <- as.factor(as.numeric(test_data$`default payment next month`) - 1)
pred_class <- as.factor(pred_class)

cm <- confusionMatrix(pred_class, actual, positive = "1")
cm_matrix <- cm$table

cm_long <- expand_grid(
  Actual = as.numeric(colnames(cm_matrix)),
  Prediction = as.numeric(rownames(cm_matrix))
) |> 
  mutate(
    Count = c(cm_matrix),
    Actual_Label = factor(Actual, labels = c("No Default (0)", "Default (1)")),
    Prediction_Label = factor(Prediction, labels = c("No Default (0)", "Default (1)"))
  )

png("Report/images/05_confusion_matrix.png", width = 800, height = 600)
ggplot(cm_long, aes(x = Actual_Label, y = Prediction_Label, fill = Count)) +
  geom_tile(color = "black", linewidth = 1) +
  geom_text(aes(label = Count), fontface = "bold", size = 6, color = "white") +
  scale_fill_gradient(low = "#fee5d9", high = "#a50f15") +
  scale_y_discrete(limits = rev(levels(cm_long$Prediction_Label))) +
  labs(title = "Confusion Matrix Heatmap",
       x = "Actual Class",
       y = "Predicted Class",
       fill = "Count",
       subtitle = "Correct predictions on diagonal (TN top-left=6815, TP bottom-right=492)") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10, color = "gray40"),
        axis.text = element_text(size = 11),
        panel.grid = element_blank())
dev.off()
print("✓ Saved: 05_confusion_matrix.png")

# ============================================================================
# 6. ROC CURVE - EXACT FROM RMD
# ============================================================================
roc_obj <- roc(actual, pred_prob, positive = "1", direction = "<", smooth = FALSE)
auc_value <- auc(roc_obj)

png("Report/images/06_roc_curve.png", width = 800, height = 600)
plot(NA,
     main = "ROC Curve",
     xlim = c(1, 0),
     ylim = c(0, 1),
     xlab = "Specificity",
     ylab = "Sensitivity",
     xaxs = "i",
     yaxs = "i")

grid(nx = 5, ny = 5, col = "lightgray", lty = 1)

abline(1, -1, lty = 2, col = "gray", lwd = 1.5)

lines(roc_obj$specificities, roc_obj$sensitivities, col = "steelblue", lwd = 2)

legend("bottomright", paste("AUC =", round(auc_value, 4)),
            cex = 1.1, bty = "o", bg = "white")
dev.off()
print("✓ Saved: 06_roc_curve.png")

print("\n✓✓✓ All images extracted and saved successfully with EXACT RMD code! ✓✓✓")
