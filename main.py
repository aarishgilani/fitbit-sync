import streamlit as st
import pandas as pd

#TODO: Add authentication using Google OAuth
# connect to postgres database and fetch meal plans

# Start of the Streamlit app
st.write("# FitBit Nutrition Helper", ":shallow_pan_of_food:")

st.write("""
    FitBit Nutrition Helper helps create meal plans and syncs them to your FitBit account.
""")

# Sidebar for meal plan options
st.sidebar.write("## Meal Plan Options")

st.sidebar.selectbox(
    "Choose a meal plan:",
    ("Keto", "Vegan", "Mediterranean", "Paleo", "Low-Carb")
)

# Display available meal plans
dataframe = pd.DataFrame({
    "Meal Name": {
      0: "Chicken Burger with Rice",
      1: "Beef Burger with Rice",
      2: "Udon Noodels with Veggies",
    },

    "Appx Cals": {
        0: 230,
        1: 250,
        2: 300,
        3: 200,
        4: 400
    },

    "Protein (g)": {
        0: 25,
        1: 30,
        2: 15,
        3: 20,
        4: 35
    },

    "Frequency": {
        0: "Daily",
        1: "Weekly",
        2: "Monthly",
        3: "Daily",
        4: "Weekly"
    },
})

st.write("## Available Meal Plan")
st.dataframe(dataframe, use_container_width=True)

mealPlan = st.selectbox("Show Meal Plan Details for:", {
    "Chicken Burger with Rice",
    "Beef Burger with Rice",
    "Udon Noodles with Veggies"
})

if mealPlan:
    st.write(f"### Details for {mealPlan}")
    details = dataframe[dataframe["Meal Name"] == mealPlan].T
    details.columns = ["Value"]
    st.table(details)