A Telerehabilitation Platform for Range of Motion Assessment Validated with a User Study for Measurement Accuracy and Usability


Data from 17 subjects is present in kinect+imudata folder.
The scripts for dataanalysis is presented in dataanalysis_scripts folder.

Data analysis execution:
Step 1: RMSE and peaks calculation is present in file "dataanalysis_individual.m" file. It compiles a text file in each subject's folder titled "Subject ID". This file contains all the peaks and RMSE in a text file.
Step 2: The text file data is copied into the Excel sheet in final folder inside kinect+imudata with filename "final.xlsx"
Step 3: Step two is repeated to compile all the data into an excel sheet for RMSE calculations. 
Step 4: RMSE sheet inside final.xlsx compiles the RMSE for trials 1-8 and finds the mean and standard deviation for each exercise. There are a total of 10 exercises.
Step 5: Steps 1 through 4 is repeated with dataanalysis_dtw_normalized.m and final_dtw.xlsx for Dynamic Time Warped Data.
Step 6: The peaks obtained between the Kinect and WISE system after normalized DTW is used for computing ICC and presented in file "ICC_mhealth_afterdtw_normalized.m"
Step 7: The "Bland_Altman_tukey.m" file opens all the data from 17 subjects and draws the Bland Altman plots with Tukey's data rejection strategy.


For further details please contact Ashwin R: ark440@nyu.edu 
